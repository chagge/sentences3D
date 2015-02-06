function word = KC_GenerateSyns(classes)
%%Synonyms Generator
% Retrieve set of synonyms in WordNet and store it in certain data
% structure.
%ARGS:
%    classes - a vector of cell. In the cell there is a word. such as classes{1}='mantel'
%
%RETURN:
%    word - a vector of struct. word(1).synonyms is a set of synonyms of classes{1};
%           such as word(1).synonyms = ' mantel mantelpiece mantle mantlepiece chimneypiece '
%                               word(1).word is the original word. Such as
%                               word(1).word = 'mantel'
%
%ATTENTION: 
%    The word in classes as args must be a noun, otherwise, please
%    take it out and then run this function. Such as if classes contains 
%    word 'other', it will trouble.
for i = 1:size(classes,1);
    word(i).word = char(classes(i,1));
    word(i).synonyms = [' ',word(i).word,' '];
    word(i).synonyms_c = {word(i).word};
    s = KC_Syns(word(i).word);
    SynSet = char(s.ShowSynSet);
    la_comma = regexp(SynSet,',');
    for j = 1:size(la_comma,2)-1;
        word(i).synonyms = [word(i).synonyms, ...
            SynSet(la_comma(1,j)+2:la_comma(1,j+1)-1),' '];
        word(i).synonyms_c = [word(i).synonyms_c, ...
            SynSet(la_comma(1,j)+2:la_comma(1,j+1)-1)];
    end
    if j >0;
        word(i).synonyms = [word(i).synonyms, ...
            SynSet(la_comma(1,j+1)+2:end-1),' '];
        word(i).synonyms_c = [word(i).synonyms_c, ...
            SynSet(la_comma(1,j+1)+2:end-1),' '];
    end   
end