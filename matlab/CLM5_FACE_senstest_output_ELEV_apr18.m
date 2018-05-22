

%%%%%%%%%%%%%%%%%%% LOOKING AT NCL FILES IN Matlab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% force matlab to write graphics correctly.... 
%opengl neverselect
					   
% If we re-run this script, we need to close all the existing figures and void the existing variables 
mkfigs=1

if(mkfigs ==1)
close all
clear all
mkfigs=1
end
figdir = 'figures'
u=3600*24*365'
vars         = ({'GPP','NPP','TLAI','QVEGT','TOTVEGC','BTRANMN','COST_NFIX','COST_NRETRANS','NPP_NUPTAKE','NACTIVE','NFIX','NRETRANS','LEAFN'})
namevars     = ({'Gross Production (gCm^{-2}y^{-1})','Net Production (gCm^{-2}y^{-1})','Leaf Area Index (m^{2}m^{-2})','QVEGT','Total Veg Carbon (Kgm^{-2})' ,'BTRANMN' ,'COST NFIX','COST RETRANS' ,'N uptake cost (gCm^{-2}y^{-1})','NACTIVE','NFIX','NRETRANS','Leaf Nitrogen (g m^{-2})'})
miny            = [3550  1400    6    1500    15700             1       10           10           0.4              10         10         5    0]
maxy            = [3350  1100    7    1500    19000             1       10           10              0.4           10         10       5      3]
unit_conversion = [u      u      1      u      1/1000             1       1            1               u              u         u        u  1]
co2max          = [3.1    4      3.2    1      1.5            1       1            1               14             1         1        1 1]
co2max          = co2max.*0 +1.9
namevarsco2     = ({'\delta Gross Production)','\delta Net Production','\delta Leaf Area Index','QVEGT','\delta Total Veg Carbon' ,'BTRANMN' ,'COST NFIX','COST RETRANS' ,'\delta N uptake cost','NACTIVE','NFIX','NRETRANS','\delta Leaf Nitrogen'})

params  = {'slatop','froot:leaf','stem:leaf','ncosts',...
'fracfixers','leafcn','grperc','medlynslope',...
'lmr-intercept','frac-ectomy-fungi','cn-flex-a','cn-flex-b',...
'cn-flex-c','luna'}


root = 'CLM5_1x1pt_Br-cax_ens_PI'
ending = '_ens_transient_ELEV_'
sitenames = {'1x1pt_Br-cax' 'bci_0.1x0.1_v4.0i' '1x1pt_US-ORN'}

ichoose = 1:4  % loop roun iterations for each parameter
vchoose = [1 2 3 5 13]; % variables.
ychoose = 1995; %choose year
mchoose = 6 %6:9 %choose month
fileend = '.nc'
 pr=1 %are we printing figures?
anom=0; %are we doing anomolies?
schoose = 1:3
fleafcn=0
fmrf=0
arc=1 %in archive? 
nploth = 2;nplotv=1 %plots
co2response =1

imap = [1 2 4 5]
N=13

X = linspace(0,pi*3,1000); 
Y = bsxfun(@(x,n)sin(x+2*n*pi/N), X.', 1:N); 
colord = linspecer(N); 
colord = [1.0  0.0  0.0;...
          0.7  0.0  0.0;...
          0.8  0.1  0.4;...
          0.8  0.6  0.1;...
          0.0  0.0  1.0;...
          0.0  0.6  0.8;...
          0.5  0.0  0.8;...
          0.4  0.4  0.4;...
          0.1  0.1  0.1;...
          0.8  0.8  0.8;...
          0.0  1.0  0.0;...
          0.1  0.8  0.6;...
          0.6  0.8  0.1]


set(0,'DefaultAxesColorOrder',colord)

for s=schoose
  root = strcat('CLM5_',char(sitenames(s)),ending,'PI')
  clear('var_arrayl','var_array2');
  for pp =[5]

    if(pp==1);pchoose=[ 1 2 3];end
    if(pp==2);pchoose=[ 4 5 6 7];end
    if(pp==3);pchoose=[ 11 12 13 ];end
    if(pp==4);pchoose=[ 8 9 14];end 
    if(pp==5);pchoose=[ 1:13];end   


    for p=pchoose %parameter loop. 
	pstr=char(num2str(p))
	for i=ichoose %iteration loop. 
	   istr=char(num2str(i))

	   dirname = strcat(root,pstr,istr)

	   if(arc==0)
	   dir_clm = strcat('/glade/scratch/rfisher/',dirname,'/run/')
	   else
	   dir_clm = strcat('/glade/scratch/rfisher/archive/',dirname,'/lnd/hist/')
	   end

	   for v = vchoose			
	      for y = ychoose 
		 for m=mchoose								
		    filen = strcat(dirname,'.clm2.h0.',num2str(y,'%04d'),'-',num2str(m,'%02d'),'.nc');
		    filename = strcat(dir_clm,filen)
		    rawvar = ncread(filename,char(vars(v)));
		    vm(m) = rawvar(1).*unit_conversion(v);						     
		 end %month
	      end %years

	      var_arrayl(p,imap(i),v) = sum(vm)/length(mchoose);
             if(v==9);var_arrayl(p,imap(i),v) = var_arrayl(p,imap(i),v)./var_arrayl(p,imap(i),2);end
            if(v==13);var_arrayl(p,imap(i),v) = var_arrayl(p,imap(i),v)./var_arrayl(p,imap(i),3);end
	   end % v
	end	%i
    end %p


    %read default

    defdirname = strcat(root,'00')


    dir_clm = strcat('/glade/scratch/rfisher/archive/',defdirname,'/lnd/hist/')
%    dir_clm = strcat('/glade/scratch/rfisher/',defdirname,'/run/')
    for v = vchoose			
      for y = ychoose
	 for m=mchoose								
	    filen = strcat(defdirname,'.clm2.h0.',num2str(y,'%04d'),'-',num2str(m,'%02d'),'.nc');
	    filename = strcat(dir_clm,filen)
	    rawvar = ncread(filename,char(vars(v)));
	    vm(m) = rawvar(1).*unit_conversion(v);						     
	 end %month
      end %years
      i=3
      for p=pchoose
        var_arrayl(p,i,v) = sum(vm)/length(mchoose);
if(v==9);var_arrayl(p,(i),v) = var_arrayl(p,(i),v)./var_arrayl(p,(i),2);end
if(v==13);var_arrayl(p,(i),v) = var_arrayl(p,(i),v)./var_arrayl(p,(i),3);end
      end
    end % v


    figure
    var_array = var_arrayl(pchoose,:,:);
    vcount = 1
    for v=vchoose
       subplot(2,3,vcount)
       vr=var_array(:,:,v)'
       vrf=vr %/vr(2,1);
       h=plot(vrf,'.-','markersize',16);axis tight
       ylabel(namevars(v));
       % ylim([ min(min(var_array(:,:,v)))*0.5 max(max(var_array(:,:,v)))*1.5])
       vcount = vcount+1
       ylim([0 maxy(v)])
       axis tight
       set(gca,'XTickLabels',[-1 0 1],'XTick',[1 3 5])
    end

    if(vcount==6)
       xlabel('Relative Parameter Deviation')
    end
    l=legend(params(pchoose))
    set(l,'position', [0.7551    0.2585    0.1393    0.0729])
    if(pr==1)
      wysiwyg
      fnm = strcat(figdir,'/frac_deviation_p',char(num2str(pchoose(1))),root,'_y',char(num2str((pchoose(1)))),'.png') 
      print('-dpng', '-r100', char(fnm) )
    end
    
    
    
    if(co2response==1)
    ychooseco2 = 2004
       for p=pchoose %parameter loop. 
	   pstr=char(num2str(p))
	   for i=ichoose %iteration loop. 
	      istr=char(num2str(i))

	      dirname = strcat(root,pstr,istr)

	      if(arc==0)
	      dir_clm = strcat('/glade/scratch/rfisher/',dirname,'/run/')
	      else
	      dir_clm = strcat('/glade/scratch/rfisher/archive/',dirname,'/lnd/hist/')
	      end

	      for v = vchoose			
		 for y = ychooseco2 
		    for m=mchoose								
		       filen = strcat(dirname,'.clm2.h0.',num2str(y,'%02d'),'-',num2str(m,'%02d'),'.nc');
		       filename = strcat(dir_clm,filen)
		       rawvar = ncread(filename,char(vars(v)));
		       vm(m) = rawvar(1).*unit_conversion(v);						     
		    end %month
		 end %years

		 var_array2(p,imap(i),v) = sum(vm)/length(mchoose);
                  if(v==9);var_array2(p,imap(i),v) = var_array2(p,imap(i),v)./var_array2(p,imap(i),2);end
                  if(v==13);var_array2(p,imap(i),v) = var_array2(p,imap(i),v)./var_array2(p,imap(i),3);end
	      end % v
	   end	%i
       end %p
       
       %read default


%       dir_clm = strcat('/glade/scratch/rfisher/',defdirname,'/run/')
 dir_clm = strcat('/glade/scratch/rfisher/archive/',defdirname,'/lnd/hist/')

       for v = vchoose			
	 for y = ychooseco2 
	    for m=mchoose								
	       filen = strcat(defdirname,'.clm2.h0.',num2str(y,'%02d'),'-',num2str(m,'%02d'),'.nc');
	       filename = strcat(dir_clm,filen)
	       rawvar = ncread(filename,char(vars(v)));
	       vm(m) = rawvar(1).*unit_conversion(v);						     
	    end %month
	 end %years
	 i=3
	 for p=pchoose
           var_array2(p,i,v) = sum(vm)/length(mchoose);
          if(v==9); var_array2(p,(i),v) = var_array2(p,(i),v)./var_array2(p,(i),2);end
          if(v==13);var_array2(p,(i),v) = var_array2(p,(i),v)./var_array2(p,(i),3);end
	 end
       end % v

       
       figure
       var_array1 = var_arrayl(pchoose,:,:);
       var_array2 = var_array2(pchoose,:,:);
       if(pp==5)
        resp = var_array2(:,:,2)./var_array1(:,:,2)
       csvwrite('respco2.csv',resp)
       end
       vcount = 1
       for v=vchoose
	  subplot(2,3,vcount)
	  vr1=var_array1(:,:,v)'
	  vr2=var_array2(:,:,v)'
	  vrf=vr2./vr1 %/vr(2,1);
	  h=plot(vrf,'.-','markersize',16);axis tight
	  ylabel(namevarsco2(v));
	  %xlim([0.5 6.5])
%	  ylim([ 1 co2max(v)])
          axis tight
	  % ylim([ min(min(var_array(:,:,v)))*0.5 max(max(var_array(:,:,v)))*1.5])
	  vcount = vcount+1
	  %ylim([0 maxy(v)])
	  set(gca,'XTickLabels',[-1 0 1],'XTick',[1 3 5])
       end

       if(vcount==6)
	  xlabel('Relative Parameter Deviation')
       end

       l=legend(params(pchoose))
       set(l,'position', [0.7551    0.2585    0.1393    0.0729])
       if(pr==1)
	 wysiwyg
	 fnm = strcat(figdir,'/frac_deviation_CO2_response_',char(num2str(pchoose(1))),root,'_y',char(num2str((pchoose(1)))),'.png') 
	 print('-dpng', '-r100', char(fnm) )
       end
       
    end %co2response    
  end %pp
end %site

