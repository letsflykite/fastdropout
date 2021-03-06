function [tnll,g] = LogisticOnevsAllLossDetObjDropoutDelta(W,X,Y,ps)
% W(feature,class)
% X(instance,feature)
% Y(instance,class) in 1 of K encoding
K = size(Y,2);
W = reshape(W, [], K);
tnll = 0;
g = zeros(size(W));
[n,p] = size(X);
pvec = ps * ones(p, 1);

for k = 1:K
    w = W(:,k);
    y = 2*Y(:,k)-1;
    
    % uncomment next line to dropout bias at a different rate
    % pvec(1) = 0.8;
    alpha = 1;
    
    EXw = X*(w .* pvec);
    X2 = X.*X;
    SigmaXw2 = alpha.*(X2) * (w.*w.*pvec.*(1-pvec));

    kappa = 0.125*pi;
    one_plus_sigma = (1 + kappa.*SigmaXw2);
    c = 1./sqrt(one_plus_sigma);

    sigycEx = sigmoid(y.*c.*EXw);
    nlldet = -sum(log( sigycEx ) ./ c);
    dmu = -y.*(1-sigycEx);

    dsigma = alpha.*kappa.*c.*( y.*EXw.*(1-sigycEx).*c...
        - log(sigycEx)); % *0.5
    dEx = pvec .* (dmu'*X)';
    dS2 = w.*pvec.*(1-pvec) .* (dsigma'*X2)'; % *2
    
    g(:,k) =  dEx + dS2;
    tnll = tnll + nlldet;
end
g=g(:);