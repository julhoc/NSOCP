% Example 2. Kato-Fukushima example of for nonlinear second-order
% cone programs as presented in [1]
% Experiment 2: Non-Linear constrain
% [1] Kato, H., Fukushima, M. An SQP-type algorithm for nonlinear 
% second-order cone programs. Optimization Letters 1, 129�144 (2007). 
% https://doi.org/10.1007/s11590-006-0009-2

% set seed
seed = RandStream('mt19937ar','Seed',1);

% choice of cones for the example
%mj= [5;5];
%mj= [5;5;20];
%mj=[5;5;20;20];
%mj=[10;10;20;20;10];
mj=[10;10;20;20;20;20];
%mj=[20;20;30;30;20;30;10];
%mj=[30;30;40;40;30;30;40];
%mj=[40;40;50;50;50;40;30;40];
%mj=[50;60;70;70;50;60;60;60];
%mj=[60;70;70;70;60;70;60;70;50];
%mj=[80;90;90;90;80;100;80;70;60];

n = sum(mj);
nCones=length(mj);
first = ones(nCones,1);
last = mj;
for i=2:nCones
    first(i) = last(i-1)+1;
    last(i) = last(i-1)+mj(i);
end

C=-1 + 2*rand(seed,n,n);
a1=-1 + 2*rand(seed,n,1);
a2=-1 + 2*rand(seed,n,1);
e=-1 + 2*rand(seed,n,1);
f=-1 + 2*rand(seed,n,1);

d=rand(seed,n,1);
b=zeros(n,1);
for i=1:nCones
    b(first(i))= 1;
end
y0 = b;

% generate random initial data until a feasible starting condition is found
default_options = options_class();
t = 1;
x0 = (-1+2*rand(seed,n,1))*t;
%a negative value of lamb_min means that the initial data is unfeasible
lamb_min = spectral_decomposition(g_kato2_nlin(x0,a1,a2,b),mj);

while(min(lamb_min) < default_options.TolCon(1))
   t = 0.8*t;
   x0 = (-1+2*rand(seed,n,1))*t;
   lamb_min = spectral_decomposition(g_kato2_nlin(x0,a1,a2,b),mj);
end


disp('x0= ');disp(x0); 
disp ('lambda gj= '); disp(lamb_min);

disp('experiment 1: Hessian update bfgs');
my_options = fdipa_options('Display', 'iter', 'TolX',1e-4,'Maxiter',100, ...
    'Hessian','bfgs');
xmin=fdipa(@(x)fun_kato2(x,C,d,e,f),x0,y0,@(x)g_kato2_nlin(x,a1,a2,b), ...
    mj,my_options);

disp('experiment 1: Hessian update Mod-Newton');
my_options = fdipa_options('Display', 'iter', 'TolX',1e-4,'Maxiter',100,...
    'Hessian','mod-newton','Hessfnc', ...
    @(xkyk)hess_update_kato2(xkyk,C,d,e,a1,a2));    
xmin=fdipa(@(x)fun_kato2(x,C,d,e,f),x0,y0,@(x)g_kato2_nlin(x,a1,a2,b), ...
    mj,my_options);


clear 'a1' 'a2' 'b' 'C' 'd' 'e' 'f' 'i' 'first' 'lamb_min' 'last' 'mj' ...
    'my_options' 'n' 'nCones' 'seed' 'x0' 'xmin' 'y0'