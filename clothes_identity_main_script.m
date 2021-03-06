
warning off
%pctRunOnAll warning('off','all')
clear all
close all
clc

flag = true;

addpath('./BSplineFitting');
addpath('./Functions');
addpath('./Classification');
addpath('./libSVM');
addpath('./SurfaceFeature');
addpath('./SpatialPyramid');
addpath(genpath([pwd,'/GPML']));
addpath('./ShapeContent');
addpath('./Utilities');
addpath('./vlfeat/toolbox');
addpath(genpath('./RandomForest'));
addpath('./FINDDD');
addpath('./myGP');

vl_setup
startup

%% script setting
coding_opt = 'LLC'
para.isnorm = 1

para.local.bsp = 1;
para.local.finddd =0;
para.local.lbp = 0;
para.local.sc = 0;
para.local.dlcm = 0;
para.local.sift = 0;

para.global.si = 1;
para.global.lbp = 1;
para.global.topo = 1;
para.global.dlcm = 0;
para.global.imm = 0;
para.global.vol = 0;

% the file is start with date to distinguish
flile_header = 'ProcessedData';
%create firectory
dataset_dir = ['~/clothes_dataset_RH/',flile_header];

% clothes is the number of flattening experiments, n_iteration is the
% number of flattening iteration in each experiment [1:7,10:12,15:16];
clothes = [1:50];

% test 1 [2:5, 7:9, 11, 13:20, 22:50]
cat1 = [ 1     2     3     4     5    27    28    29    30    45 ];
cat2 = [ 6     7     8     9    22    23    32    33    34    35 ];
cat3 = [ 10    11    13    17    18    46    47    48    49    50 ];
cat4 = [ 12    14    15    16    19    20    26    31    36    37 ];
cat5 = [ 21    24    25    38    39    40    41    42    43    44 ];


captures = 0:20;


%% main loop

Instance = [];
Label = [];
ClothesID = [];

for iter_i = 1:length(clothes)
    clothes_i = clothes(iter_i);
    disp(['start read descriptors of clothes id: ', num2str(clothes_i), ' ...']);
    
    if clothes_i < 10
        current_dir = strcat(dataset_dir,'/0',num2str(clothes_i),'/');
    else
        current_dir = strcat(dataset_dir,'/',num2str(clothes_i),'/');
    end
    
    % read the label information
    labelFile = strcat(current_dir,'info.mat');
    load(labelFile);
    
    switch category
        case 't-shirt'
            label = 1;
        case 'shirt'
            label = 2;
        case 'thick-sweater'
            label = 3;
        case 'jean'
            label = 4;
        case 'towel'
            label = 5;
        otherwise
            pause        
    end
    
    % feature extraction
    for iter_j = 1:length(captures)
        
        capture_i = captures(iter_j);
        
        local_feature = [];
        global_feature = [];
        
        %% read features from the disk
        % read local features (code)
        localFeatureFile = strcat(current_dir,coding_opt,'_codes_capture',num2str(capture_i),'.mat');
        
        if ~exist(localFeatureFile,'file')
            continue;
        else
            load(localFeatureFile);
        end
        
        if para.local.bsp
            local_feature = [ local_feature, code.bsp ];
        end
        if para.local.finddd
            local_feature = [ local_feature, code.finddd ];
        end
        if para.local.lbp
            local_feature = [ local_feature, code.lbp ];
        end
        if para.local.sc
            local_feature = [ local_feature, code.sc ];
        end
        if para.local.dlcm
            local_feature = [ local_feature, code.dlcm ];
        end
        if para.local.sift
            local_feature = [ local_feature, code.sift ];
        end
        
        % read global features
        globalFeatureFile = strcat(current_dir,'global_descriptors_capture',num2str(capture_i),'.mat');
        load(globalFeatureFile);
        
        if para.global.lbp
            global_feature = [ global_feature, global_descriptors.lbp ];
        end
        if para.global.si
            global_feature = [ global_feature, global_descriptors.si ];
        end
        if para.global.topo
            global_feature = [ global_feature, global_descriptors.topo ];
        end
        if para.global.dlcm
            global_feature = [ global_feature, global_descriptors.dlcm];
        end
        if para.global.imm
            global_feature = [ global_feature, global_descriptors.imm];
        end
        if para.global.vol
            global_feature = [ global_feature, global_descriptors.vol];
        end        
        
        instance = [ local_feature, global_feature ];
        
        Instance = [ Instance; instance ];
        Label = [ Label; label ];
        ClothesID = [ ClothesID; clothes_i ];
        
        clear instance;
    end
    %%
    disp(['fininsh reading of clothing ', num2str(clothes_i), ' ...']);
    clear label1 label2;
end


%% generate model for robot practice
if para.isnorm
    [ Instance Label norm ] = prepareData( Instance, Label );
else
    norm = [];
end

clearvars -except Instance Label ClothesID norm; 


%% traning model for robot practical recognition
%train SVM model
svm_opt = '-s 0 -c 10 -t 2 -g 0.01';

% % svm_struct = libsvmtrain( Label, Instance, svm_opt );
% % save('classifier_demo.mat','svm_opt','norm','svm_struct');
% % %%

%% training GP
% % kernel = @covSEiso;
% % para.kernel = kernel;
% % para.hyp = log([ones(1,1)*46, 11]);
% % para.S = 1e4;
% % labels = unique(Label);
% % c = length(labels);
% % para.c = c;
% % para.Ncore = 12;
% % para.flag = true; 
% % hyp = para.hyp;
% % gp_para = para;
% % 
% % % estimate the posterior probility of p(f|X,Y)
% % [ K ] = covMultiClass(hyp, para, Instance, []);
% % [ gp_model ] = LaplaceApproximation(hyp, para, K, Instance, Label);
% % save('classifier_gp_demo.mat','gp_model','norm','gp_para');

%%

% % % % % % training random forest
% % rf_opt.treeNum = 1000;
% % rf_opt.mtry = 200;
% % rf_struct = classRF_train( Instance, Label, rf_opt.treeNum, rf_opt.mtry );
% % save('classifer.mat', 'rf_opt', 'rf_struct');

    
%% classfication varification
fold = 5;
expNum = 10;
para.opt = svm_opt;
para.cv_mode = 'clothes';
labels = unique(Label);
c = length(labels);
para.c = c;
para.Ncore = 12;
para.flag = true; 


[ result_svm ] = x_fold_CV( Instance, Label, ClothesID, fold, expNum, 'SVM', para );


disp('press Enter to continue ...');
pause
close all

%%  set Gaussian Process parameters

kernel = @covLINiso;

fold = 2;
expNum = 1;
isnorm = 1;

para.kernel = kernel;

para.hyp = log([11]);

para.model_selection = 1;
para.sampe_rate = 0.3;

para.labels = labels;
para.fold = fold;
para.isnorm = isnorm;
para.S = 1e4;
para.cv_mode = 'clothes';
%%


[ result ] = x_fold_CV( Instance, Label, ClothesID, fold, expNum, 'myGP', para );


% % for expi = 1:1
% %     [ result ] = LeaveOneOutValidification(Instance, Label, ClothesID, 'SVM', para );
% % end

