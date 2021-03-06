function [ modelA modelB ] = Joint2HorizontalPatchesC0( modelA, modelB )

    % joint the west model
    % ModelA refers to west one, model B refers to the east one

    if isempty(modelA) || isempty(modelB)
        return;
    end
    
    B_A(:,:,1) = reshape(modelA.B(:,1),[modelA.bnum_u,modelA.bnum_w]);
    B_A(:,:,2) = reshape(modelA.B(:,2),[modelA.bnum_u,modelA.bnum_w]);
    B_A(:,:,3) = reshape(modelA.B(:,3),[modelA.bnum_u,modelA.bnum_w]);
    B_B(:,:,1) = reshape(modelB.B(:,1),[modelB.bnum_u,modelB.bnum_w]);
    B_B(:,:,2) = reshape(modelB.B(:,2),[modelB.bnum_u,modelB.bnum_w]);
    B_B(:,:,3) = reshape(modelB.B(:,3),[modelB.bnum_u,modelB.bnum_w]);
    
    %%
% %     figure(2)
% %     plot3(modelA.D(:,1),modelA.D(:,2),modelA.D(:,3),'b+')
% %     hold on
% %     plot3(modelB.D(:,1),modelB.D(:,2),modelB.D(:,3),'r+')
% %     hold on
% %     plot3(B_A(2:end-1,end,1),B_A(2:end-1,end,2),B_A(2:end-1,end,3),'r*');
% %     hold on 
% %     plot3(B_B(2:end-1,1,1),B_B(2:end-1,1,2),B_B(2:end-1,1,3),'b*');
% %     close(2)
    %%
    
    %% C0 joint
    B_A(2:end-1,end,:) = (B_A(2:end-1,end,:) + B_B(2:end-1,1,:)) / 2;
    B_B(2:end-1,1,:) = B_A(2:end-1,end,:);
    %%
    
    %%
    modelA.B(:,1) = reshape(B_A(:,:,1),[modelA.bnum_u*modelA.bnum_w,1]);
    modelA.B(:,2) = reshape(B_A(:,:,2),[modelA.bnum_u*modelA.bnum_w,1]);
    modelA.B(:,3) = reshape(B_A(:,:,3),[modelA.bnum_u*modelA.bnum_w,1]);
    modelB.B(:,1) = reshape(B_B(:,:,1),[modelB.bnum_u*modelB.bnum_w,1]);
    modelB.B(:,2) = reshape(B_B(:,:,2),[modelB.bnum_u*modelB.bnum_w,1]);
    modelB.B(:,3) = reshape(B_B(:,:,3),[modelB.bnum_u*modelB.bnum_w,1]);

    