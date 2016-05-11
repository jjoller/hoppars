function [ y ] = symmetric_extend( f )
%SYMMETRIC_EXTEND Summary of this function goes here
%   Detailed explanation goes here
    if imag(f(end)) == 0
        toinvert = f(1:end-1);
    else
        toinvert = f;
    end
    finv = flipud(conj(toinvert(2:end)));
    y = [f;finv];

end

