
function [pos1, len1, pos0, len0] = extractLength(d)
%   [pos1, len1, pos0, len0] = extractLength(d)
% receive a data sequence d containing zeros and ones
% extract the position and length of all zeros and all ones

%   converts the data to a sequence of all zeros or one
d = double(boolean(d));

len = diff([0 find(diff(d)) length(d)]);
df = [0 diff(d)];
pos = [1 find(df)];

if (d(1) == 0)
    len0 = len(1:2:end);
    len1 = len(2:2:end);
    pos0 = pos(1:2:end);
    pos1 = pos(2:2:end);
else
    len1 = len(1:2:end);
    len0 = len(2:2:end);
    pos1 = pos(1:2:end);
    pos0 = pos(2:2:end);
end

end