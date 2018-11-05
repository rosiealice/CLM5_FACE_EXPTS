%%%%%%%%%%%%%%%%%%% LOOKING AT NCL FILES IN Matlab %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% force matlab to write graphics correctly....
%opengl neverselect

% If we re-run this script, we need to close all the existing figures and void the existing variables
mkfigs = 1

if (mkfigs == 1)
  close all
  clear all
  mkfigs = 1
end
figdir = 'figures'
u = 3600 * 24 * 365'
vars = ({'GPP', 'NPP', 'TLAI', 'QVEGT', 'TOTVEGC', 'BTRANMN', 'COST_NFIX', 'COST_NRETRANS', 'NPP_NUPTAKE', 'NACTIVE', 'NFIX', 'NRETRANS','LEAFN'})
namevars = ({'Gross Production (gCm^{-2}y^{-1})', 'Net Production (gCm^{-2}y^{-1})', 'Leaf Area Index (m^{2}m^{-2})', 'QVEGT', 'Total Veg Carbon (gm^{-2})', 'BTRANMN', 'COST NFIX', 'COST RETRANS', 'N uptake cost (gCm^{-2}y^{-1})', 'NACTIVE', 'NFIX', 'NRETRANS','N_{area}'})
%maxy            = [3050  1400    6    1500    15700             1       10           10           0.4              10         10         5]
maxy = [2350 1100 7 1500 19000 1 10 10 0.4 10 10 5 3]
unit_conversion = [u u 1 u 1 1 1 1 u u u u 1 ]
co2max = [2.5 2.5 2.5 1 1.5 1 1 1 14 1 1 1 1.5]
namevarsco2 = {'\delta Gross Production)', '\delta Net Production', '\delta Leaf Area Index', 'QVEGT', '\delta Total Veg Carbon', 'BTRANMN', 'COST NFIX', 'COST RETRANS', '\delta N uptake cost', 'NACTIVE', 'NFIX', 'NRETRANS','\delta N_{area}'}

params = {'slatop', 'froot:leaf', 'stem:leaf', 'ncosts', ...
  'fracfixers', 'leafcn', 'grperc', 'medlynslope', ...
  'lmr-intercept', 'frac-ectomy-fungi', 'cn-flex-a', 'cn-flex-b', ...
  'cn-flex-c', 'luna', '', '', 'p1', 'denit resp coef', 'denit resp exp', 'denit nit coef ', 'denit nit exp'}

sitenames = {'1x1pt_Br-cax' ,'1x1pt_US-NR1' '1x1pt_US_Ha1', '1x1pt_US-Me2', '1x1pt_US-ORN' '1x1pt_US-Brw' }

ichoose = 1:5 % loop roun iterations for each parameter
vchoose = [1 2 3 5 13]; % variables.
ychoose = [1990 2006]; %choose year
mchoose = 8 %6:9 %choose month
pchoose = 1:13
fileend = '.nc'
pr = 0 %are we printing figures?
anom = 0; %are we doing anomolies?
schoose = 1:4
fleafcn = 0
fmrf = 0
arc = 1 %in archive?
nploth = 2; nplotv = 1 %plots
co2response = 1'
figsFERT = 0
figsSTATE= 0
figsCN = 1
prSTATE = 0
prFERT = 0
prCN = 1
defaultc = 53

N = 13
X = linspace(0, pi * 3, 1000);
Y = bsxfun(@(x, n)sin(x + 2 * n * pi / N), X.', 1:N);
colord = linspecer(N);
colord = [1.0 0.0 0.0; ...
  0.7 0.0 0.0; ...
  0.8 0.1 0.4; ...
  0.8 0.6 0.1; ...
  0.0 0.0 1.0; ...
  0.0 0.6 0.8; ...
  0.5 0.0 0.8; ...
  0.4 0.4 0.4; ...
  0.1 0.1 0.1; ...
  0.8 0.8 0.8; ...
  0.0 1.0 0.0; ...
  0.1 0.8 0.6; ...
  0.6 0.8 0.1]


marks = {'.-','.--','.-','.--','.-','.--','.-','.--','.-','.--','.-','.--',...
'.-','.--','.-','.--','.-','.--','.-','.--','.-','.--','.-','.--','.-','.--',...
'.-','.--','.-','.--','.-','.--'}

marks = {'o-','o--',  'o-','o--','o-','o--','o-','o--','o-','o--','o-','o--',...
'o-','o--','o-','o--','o-','o--','o-','o--','o-','o--','o-','o--','o-','o--',...
'o-','o--','o-','o--','o-','o--','o-','o--','o-','o--','o-','o--','o-','o--'}  


for pars = 1:2
  if (pars == 1);
     pf = 'defpft';
  else;
    pf = 'hl';
  end
  set(0, 'DefaultAxesColorOrder', colord)

  for co2response= 1:2
    if (co2response == 1);
      expt = 'celev';
    else
      expt = 'ndep';
    end
    for s = schoose
      root = strcat('CLM50', char(pf), '_', char(expt), '_', char(sitenames(s)), '_ens_MIC')
      count = 0
      var_array1 = zeros(max(pchoose), max(ichoose), max(vchoose), 2);

      for p = pchoose %parameter loop.
        pstr = char(num2str(p))
        for i = ichoose %iteration loop.
          
          if(i==3) % default
            c=defaultc
          else
            count = count + 1
            c=count
          end
          
          istr = char(num2str(i))       
          dirname = root
       
          if (arc == 0)
            dir_clm = strcat('/glade/scratch/rfisher/', dirname, '/run/');
          else
            dir_clm = strcat('/glade/scratch/rfisher/archive/', dirname, '/lnd/hist/');
          end
       
          for v = vchoose
            for y = 1:2
              for m = mchoose
                filen = strcat(dirname, '.clm2_00', num2str(c, '%02d'), '.h0.', num2str(ychoose(y), '%04d'), '-', num2str(m, '%02d'), '.nc');
                filename = strcat(dir_clm, filen)
                if (exist(filename))
                  rawvar = ncread(filename, char(vars(v)));
                else
                  vm(m) = nan;
                  'no file'
                end
                vm(m) = rawvar(1) .* unit_conversion(v);
              end %month
                        
              var_array1(p, i, v, y) = sum(vm) / length(mchoose);
              if (v == 9);
                var_array1(p, i, v, y) = var_array1(p, i, v,y) ./ var_array1(p, i, 2, y);
              end
              if (v == 13);
                var_array1(p, i, v, y) = var_array1(p, i, v,y) ./ var_array1(p, i, 3, y);
              end
      
            end %years        
          end % v
        end %i
      end %p
   
      if (figsSTATE == 1)
        %state figure
        figure
        set(gcf, 'name', char(sitenames(s)))
        var_array = squeeze(var_arrayl(pchoose, :, :, 1));
        vcount = 1
        for v = vchoose
          subplot(2, 3, vcount)
          vr = var_array(:, :, v)'
          vrf = vr ;
          h = plot(vrf, '.-', 'markersize', 16); axis tight
          ylabel(namevars(v));
          %xlim([0.5 6.5])
          %ylim([ 0.5 1.5])
          % ylim([ min(min(var_array(:,:,v)))*0.5 max(max(var_array(:,:,v)))*1.5])
          vcount = vcount + 1
          ylim([0 maxy(v)])
          axis tight
          set(gca, 'XTickLabels', [- 1 0 1], 'XTick', [1 3 5])
        end
     
        if (vcount == 6)
          xlabel('parameter deviation')
        end
        l = legend(params(pchoose))
        set(l, 'position', [0.7551 0.2585 0.1393 0.0729])
        if (prSTATE== 1)
          wysiwyg
          fnm = strcat(figdir, '/OCT_STATE_', char(num2str(pchoose(1))), root, '_y', char(num2str((pchoose(1)))), '.png')
          print('-dpng', '-r100', char(fnm))
        end
      end %figsSTATE

      if(figsFERT==1)
        figure
        set(gcf, 'name', strcat('fertresponse', char(sitenames(s)), '_', char(pf), '_', char(expt)))
      end
      vararray1 = squeeze(var_array1(pchoose, :, :, 1));
      vararray2 = squeeze(var_array1(pchoose, :, :, 2));
      vcount = 1

      vr1=vararray1(:,:,3)'
      vr2=vararray2(:,:,3)'
      diff=vr1./vr1(3,1)
      dead=find(diff<0.8)
      laiout(co2response,s,:,:)=vararray1(:,:,3);  
      for v = vchoose
        subplot(2, 3, vcount)
        vr1 = vararray1(:, :, v)';
        vr2 = vararray2(:, :, v)';
        vrf = vr2 ./ vr1 %/vr(2,1);
        vrf(dead)=nan;
        vrfout(co2response,s,v,:,:)=vrf;
        
        if(figsFERT == 1)
          h = plot(vrf, '.-', 'markersize', 16); axis tight
          ylabel(namevarsco2(v));
          %xlim([0.5 6.5])
          ylim([1.1 co2max(v)])
          % ylim([ min(min(var_array(:,:,v)))*0.5 max(max(var_array(:,:,v)))*1.5])
          vcount = vcount + 1
          
          %ylim([0 maxy(v)])
          axis tight
          set(gca, 'XTickLabels', [- 1 0 1], 'XTick', [1 3 5])
          if (vcount == 6)
           xlabel('parameter deviation')
          end
        end % figsfert
      end %v
   
      if(figsFERT ==1 )
        l = legend(params(pchoose))
        set(l, 'position', [0.7551 0.2585 0.1393 0.0729])
      end 
      if (prFERT == 1)
        wysiwyg
        fnm = strcat(figdir, '/OCT_FERT_', char(num2str(pchoose(1))), root, '_p', char(num2str((pchoose(1)))), '.png')
        print('-dpng', '-r100', char(fnm))
      end
       
    end %sitte
  end %co2response

  vrfout(2,[2 4],vchoose,1,3)=nan;

%figure
%subplot(2,1,1)
%for s=schoose
%for p=pchoose
%plot(squeeze(laiout(1,s,p,ichoose)),squeeze(vrfout(1,s,1,ichoose,p)),'.');hold on
%end
%end
%subplot(2,1,2)
%plot(laiout,squeeze(vrfout(1,:,1,:,:)),'.')

  if(figsCN == 1)
    for v=vchoose
    figure
    set(gcf,'name',strcat('rel_',char(vars(v)),'_',char(expt),'_',char(pf))) 
    for s=schoose
      smap=[1 2 4 5 ]
      ph(s)=subplot(2,3,smap(s))
      c = squeeze(vrfout(1,s,v,:,:));
      n = squeeze(vrfout(2,s,v,:,:));
      %crangemax = max(max(max(squeeze(vrfout(1,:,v,:,:)))))       
      %crangemin = min(min(min(squeeze(vrfout(1,:,v,:,:))))) 
      %nrangemax = max(max(max(squeeze(vrfout(2,:,v,:,:)))))       
      %nrangemin = min(min(min(squeeze(vrfout(2,:,v,:,:)))))     
     
      for p=pchoose
        plot(n(:,p),c(:,p),char(marks(p)),'markersize',3,'markerfacecolor',colord(p,:));hold on
      end
      if(s==3||s==4)
      xlabel('N Response')
      end
      if(s==1||s==3)
        ylabel('CO_{2} Response')
      end
      pos(s,:) = get(gca,'position');
      if(s==4)
        l=legend(params,'Location','NorthEastOutside','fontsize',7)
      end

      for i=1:5
        for p=pchoose
          plot(n(i,p),c(i,p),'o','markersize',i*0.6+3.5,'markerfacecolor',colord(p,:));hold on
        end
      end

      axis tight
      %ylim([crangemin crangemax])
      %xlim([nrangemin nrangemax])
    end %s
    for s=schoose
      set(ph(s),'position',pos(s,:))
    end

    if (prCN == 1)
      wysiwyg
      fnm = strcat(figdir, '/OCT_CNdep_', char(vars(v)),char(num2str(pchoose(1))), '_',root, '_p', char(num2str((ychoose(2)))), '.png')
      print('-dpng', '-r100', char(fnm))
    end
    end %v
  end %figsCN


end % pars


