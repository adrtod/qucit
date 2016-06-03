function out = combine(x, res)

cifers = cellfun(@num2str, num2cell(x), 'uniformoutput', 0);
n = numel(x);

sym = {' - ', ' + ', ''};
ns = numel(sym);

% out = {};
for i=0:(ns^(n-1)-1)
    s = repmat(sym(1), 1, n-1);    
    ind = cellfun(@str2num, num2cell(dec2base(i, ns)));    
    s(1:numel(ind)) = sym(ind+1);    
    expr = strjoin(altern(cifers, s)', '');    
    if eval(expr) == res
%        out{end+1, 1} = sprintf('%s = %d', expr , res);
       fprintf('%s = %d\n', expr , res);
    end
end

