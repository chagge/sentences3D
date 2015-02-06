function sen3d_main(objty, cfg, C)
%SEN3D_MAIN The main program to run Training and Testing on Sentences3d mdoel
%
%   SEN3D_MAIN(objty, cfg, C)
%
%       Runs the trainig and testing of an sentences 3D model based on
%       the input config. 
%
%       Here, objty indicates which types of cuboid we used. 
%       
%       Here, cfg can be either a config struct (loaded by in3d_config)
%       or a config filename.
%
%       Learned models and testing results will be written to the
%       directory, specified by cfg.output_dir.

%% configuration

disp('Loading configurations ...');    
cfg = sen3d_config(cfg, objty);
% save('/share/data/sentences3D/data/nn08/cfg.mat', 'cfg', '-v7.3');

%% load data

disp('Loading data ...');
S = cfg.data.S;

% split data set
split = cfg.split;
scenes_tr = S(split.train);
scenes_te = S(split.test);

fprintf('\n%d scenes (split into %d training and %d testing)\n', ...
    numel(S), numel(scenes_tr), numel(scenes_te));

%% create output directories

outdir = fullfile(cfg.output_dir);
if ~exist(outdir, 'dir')
    mkdir(outdir);        
end
fprintf('Outputs will be written to %s\n', outdir);

%% learning

tstart = tic;

disp('Constructing training features & potentials ...');

% construct feature spec
feas = sen3d_feas(cfg);

% construct sample set
[samples_tr, loss] = sen3d_scenesamples(cfg, scenes_tr);

% construct potential set
pots_tr = sen3d_pots(cfg, feas, scenes_tr, samples_tr);

if isprop(loss, 'fac_counters')
   loss = re_index_factors(loss, pots_tr);
end;

fprintf('features & potentials constructed, elapsed = %g sec\n', toc(tstart));

% training

disp('Training ...');

params = gcrf_learnparams( ...
    'iters', cfg.learning_iters, ...
    'C', C, ...
    'rgap', cfg.learning_rgap);

% load or compute empirical mean

emp_mean_fp = fullfile(outdir, 'emp_mean.mat');

if exist(emp_mean_fp, 'file')
    fprintf('loading empirical means from %s\n', emp_mean_fp);
    emp_mean = load(emp_mean_fp);
    emp_mean = emp_mean.emp_mean;
else
    fprintf('computing empirical means\n');
    emp_mean = loss.empirical_mean(pots_tr);
    
    save(emp_mean_fp, 'emp_mean');
end

fprintf('empirical-mean ready, elapsed = %g sec\n', toc(tstart));

% learn theta

% save('/share/data/sentences3D/data/nn08/pots_loss.mat', 'pots_tr', 'loss');

theta_fp = fullfile(outdir, 'theta.mat');

if exist(theta_fp, 'file')
    fprintf('loading theta (model coeffs) from %s\n', theta_fp);
    theta = load(theta_fp);
    theta = theta.theta;
    display(theta);
else
    fprintf('learning theta ...\n');
    
    tlearn = tic;
    
    th_init = ones(feas.num_features, 1);
    theta = loss.learn(pots_tr, th_init, emp_mean, params);      
    
    learning_time = toc(tlearn); %#ok<NASGU>
    
    save(theta_fp, 'theta', 'learning_time');
end
    
fprintf('model ready, elapsed = %g sec\n', toc(tstart));
disp(' ');


%% testing

info = cfg.data.info;


% test on test

tinfer = tic;

preds_te_fp = fullfile(outdir, 'predictions_test.mat');
res_te_fp = fullfile(outdir, 'results_test.mat');

fprintf('Testing on testing set\n');

if ~isempty(preds_te_fp) && exist([preds_te_fp ''], 'file')
    fprintf('loading preds from %s\n', preds_te_fp);
    preds_te = load(preds_te_fp);
    preds_te = preds_te.preds;
else
    fprintf('solving predictions\n');
    samples_te = sen3d_scenesamples(cfg, scenes_te);
    pots_te = sen3d_pots(cfg, feas, scenes_te, samples_te);

    theta_a = theta;

    preds_te = pots_te.infer(theta_a);

    preds = preds_te; %#ok<NASGU>
    save(preds_te_fp, 'preds');
end
    
base_recall_te = info.te_r / info.te_t;
c_base_recalls_te = info.c_te_r ./ info.c_te_t;
Rte = get_results(cfg, scenes_te, preds_te, base_recall_te, c_base_recalls_te);

save(res_te_fp, '-struct', 'Rte');

fprintf('testing on test-set ready, elapsed = %g sec\n', toc(tstart));
disp(' ');
    
Rte.infer_time = toc(tinfer);

f1_fp = fullfile(outdir, 'Rte.mat');
save(f1_fp, '-struct', 'Rte');



function R = get_results(cfg, scenes, preds, base_recall, base_recalls)

results = sen3d_results(cfg, scenes, preds);
R = sen3d_evalresults(cfg, scenes, results, base_recall, base_recalls);

fprintf('Result:\n');
fprintf('    scene classification:  %.4f\n', R.scene_accuracy);
if cfg.use_bias
    fprintf('    recall:     %.4f\n', mean(R.c_recall));
    fprintf('    precision:  %.4f\n', mean(R.c_precision));
    fprintf('    F1:         %.4f\n', mean(R.c_F1));
else
    fprintf('    object classification: %.4f\n', R.object_accuracy)

end
if cfg.use_a
    fprintf('    a recall: %.4f\n', R.a_recall);
    fprintf('    a precision: %.4f\n', R.a_precision);
    fprintf('    a f-measure: %.4f\n', R.a_fmeasure);
    fprintf('    a with it recall: %.4f\n', R.a_with_it_recall);
    fprintf('    a with it precision: %.4f\n', R.a_with_it_precision);
    fprintf('    a with it f-measure: %.4f\n', R.a_with_it_fmeasure);
end