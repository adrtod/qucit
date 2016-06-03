function s = sumfib(n)

u1 = 0;
u2 = 1;
s = 1;
for i=3:n
    new = u2+u1;
    u1 = u2;
    u2 = new;
    s = s + new;
end

end