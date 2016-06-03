function s = sum2(x)

s = 0;
i = 1;
while (i<=numel(x))
    s = s+x(i);
    i = i+1;
end