% Parameter file modifier for CLM5 one at a time sensitivity analyses 

close all
clear all

% where is the default parameter file?
template = '/glade/p/cesm/cseg/inputdata/lnd/clm2/paramdata/clm5_params.c171017.nc'
template = 'clm5_params.c171017_highleaf.nc'


npft = 15
natvg = [2:npft];
nv=13

pftdirname='FACE_pftfiles'

% default name of new parameter files. 
froot=char(strcat('/glade/p/work/rfisher/git/CLM5_FACE_EXPTS/matlab/',pftdirname,'/FACE_CLM_params_may1_highleaf_'))

                                          
varnames = {'slatop','froot_leaf','stem_leaf','ekn_active','akn_active','kn_nonmyc','ekc_active','akc_active','kc_nonmyc','FUN_fracfixers','leafcn','grperc','medlynslope','lmr_intercept_atkin','perecm','fun_cn_flex_a','fun_cn_flex_b','fun_cn_flex_c','leafcn'}

mult(:,1)=[  0.6761 0.8769 1.2785 1.4791]; %slatop 10^(log10(15.7)+0.17)/15.7
mult(:,2)=[  0.342 0.671 1.05 1.1 ]; % froot_leaf default 1.5. Maybe a bit high. 
mult(:,3)=[  0.3057 0.61 1 1 ]; %stem_leaf default 2.3
mult(:,4)=[  -2 -1  1 2 ]; %Ncosts
mult(:,5)=[  0 0.5 2 4  ]; %FUN_fracfixers
mult(:,6)=[  0.7413 0.8932 1.1970 1.349]; %leafcn  
mult(:,7)=[0 0.5 2 3]%grperc from 0 to the previous high value 
mult(:,8)=[ 0.5258 0.7191 1.1057 1.29 ] %medlyn slope. Full range of PFT values
mult(:,9)=[ 0.8539 0.9531 1.1512 1.25]%lmr_intercept_atkin
mult(:,10)=[0 0.5 1  1] %perecm. 1 is the default. 
mult(:,11)=[0 0.5 2  4] %fun_cn_flex_a. 5 is the default.limit beyond which there is a reduction in N uptake..
mult(:,12)=[0.1 0.5 2  4] %fun_cn_flex_b. 100 is the default.  scales the difference between a and the resistance into a reduction rate. 
mult(:,13)=[0.001 0.1 10 100] %fun_cn_flex_c. 8 is the default.  Scales the difference in leafcn. so, 8 is the differnce for which the c spent is scaled back up to one (only impacts if n costs is high)
mult(:,14)=[  0.7413 0.8932 1.1970 1.349]; %leafcn
%LUNA on & off


map       = [1 2 3 4 4 4 4 4 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19]
nmap      = [0 0 0 1 2 3 4 5 6 0 0 0 0 0 0  0  0  0  0  0  0  0  0  0]
logsample = [0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
replv     = [1 1 1 6 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]
startn    = [1 2 3 4 10 11 12 13 14 15 16 17 18 19]


for v=1:14% 1:nv %shorter number
   for i=1:4
     clear('def','new_var');
     filename =strcat(froot,'pi',char(num2str(v)),char(num2str(i)),'.nc')
     copyfile(template,filename)
     for var = 1:replv(v)
       varid = startn(v) + var -1 %large number
       vr   = char(varnames(varid));
       def    = ncread(template,vr);      
       if(logsample(v)==0)
	 adj   =  mult(i,v);
       else 	  
	 adj   =  10.^(mult(i,v));
       end
       new_var(natvg) = adj .* def(natvg);
       ncwrite(filename,char(varnames(varid)),new_var)
    end %var
  end %i  
end %v	

