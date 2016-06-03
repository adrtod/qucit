function c = altern(a,b)
c = cell(numel(a)+numel(b),1);
[m, i] = min([numel(a), numel(b)]);
c(1:2:(2*m),1) = a(1:m);
c(2:2:(2*m),1) = b(1:m);
if i == 1
    c((2*m+1):end) = b((m+1):end);
else
    c((2*m+1):end) = a((m+1):end);
end
end