%function []= BBN_excel2txt(excel_filename, seedlevs)
% RC 2021
% Converts excel file created by BBN_Compatible_Table_Func.m to a .txt file with
% suitable levels in variables to be read by Netica
% excel_filename - filename of the excel file to be converted, as a string 
% created for a text set of data
% seed levs is a 2 by 3 matrix with the levels for seeding [low and high]

% cd to location of excel files
    cd '/Users/rosecrocker/Documents/AIMS/1_ADRIA_9Aug21/ADRIAmain_scripts'

    excel_table = readtable('ADRIA_BBN_Data.xlsx'); 
    % processing PrSites column
    N = height(excel_table);
    fileID = fopen('ADRIA_BBN_Data.txt','w');
    fprintf(fileID,'%3s \t %5s \t %8s \t %8s \t %5s \t %5s \t %4s \t %11s\n',...
        'RCP','Years','Guided','PrSites','Seed1','Seed2','SRM', 'CoralCover');
     %   ,'PrSites','Seed1','Seed2','SRM','AssistedAdapt','NaturalAdapt','CoralCover');
    
  
    for k = 1:N
      tempstr = 'RCP%2.0f \t Y%2.0f ';
      if excel_table.Guided(k) == 0
          tempstr = strcat(tempstr,'\t Unguided ');
      elseif excel_table.Guided(k) == 1
          tempstr = strcat(tempstr,'\t Guided ');
      end
      if excel_table.PrSites(k) == 1
          tempstr = strcat(tempstr,'\t A ');
      elseif excel_table.PrSites(k) == 2
          tempstr = strcat(tempstr,'\t B ');
      elseif excel_table.PrSites(k) == 3
          tempstr = strcat(tempstr,'\t C');
      end
      if excel_table.Seed1(k) == 0
          tempstr = strcat(tempstr,'\t Nil ');
      elseif (excel_table.Seed1(k)) <= seedlevs(1,1) && (excel_table.Seed1(k)~= 0)
          tempstr = strcat(tempstr,'\t Low ');
      elseif (excel_table.Seed1(k)) >= seedlevs(1,2)
          tempstr = strcat(tempstr,'\t High');
      end
      if excel_table.Seed2(k) == 0
          tempstr = strcat(tempstr,'\t Nil ');
      elseif (excel_table.Seed2(k)) <= seedlevs(2,1) && (excel_table.Seed2(k)~= 0)
          tempstr = strcat(tempstr,'\t Low ');
      elseif (excel_table.Seed2(k)) >= seedlevs(2,2)
          tempstr = strcat(tempstr,'\t High');
      end
      if excel_table.SRM(k) == 0
          tempstr = strcat(tempstr,'\t Nil ');
      else 
          tempstr = strcat(tempstr,'\t DHW',num2str(excel_table.SRM(k)));
      end

      tempstr = strcat(tempstr,'\t %1.10f');
      tempstr = strcat(tempstr,' \n');
      fprintf(fileID,tempstr,[excel_table.RCP(k),excel_table.Years(k),excel_table.CoralCover(k)]);
    end
    
      fclose(fileID);
%end
