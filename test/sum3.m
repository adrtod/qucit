function s = sum3(x)

s = x(1);
if numel(x)>1
    s = s + sum3(x(2:end));
end

end