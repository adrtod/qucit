function l = largest(x)

l = fliplr(sort(arrayfun(@num2str, x, 'UniformOutput', 0)));
l = [l{:}];
