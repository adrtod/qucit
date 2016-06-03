function l = largest(x)

% pow10 = floor(log10(x));
% 
% [~,ind] = sort(floor(x./10.^pow10), 'descend');
% 
% l = sprintf('%d',x(ind));

l = fliplr(sort(arrayfun(@num2str, x, 'UniformOutput', 0)));
l = [l{:}];