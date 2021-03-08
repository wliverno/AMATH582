clear all, close all;

load pcaMats.mat;

%Collect training sets and take random sample
[trainimages, trainlabels] = mnist_parse('train-images.idx3-ubyte', 'train-labels.idx1-ubyte');
[lx, ly, n] = size(trainimages);
trainPC = getPCABasis(trainimages, uPC);

%Collect test set
[testimages, testlabels] = mnist_parse('t10k-images.idx3-ubyte', 't10k-labels.idx1-ubyte');
[lx, ly, n] = size(testimages);
nsample = 6000;
sample = randperm(n);
sample = sample(1:nsample);
testlabels = testlabels(sample);
testimages = testimages(:, :, sample);
testPC = getPCABasis(testimages, uPC);
% imshow(uint8(reshape(uPC*testPC(:,22), lx,ly)))
% testlabels(22)
% figure;

% %Set up set for LDA on two digits, specified by split1, split2
% combos = nchoosek(0:9, 2);
% probs = zeros(length(combos(:,1)), 1);
% for i=1:length(combos)
%     subset=ismember(trainlabels, combos(i,:));
%     trainPC2 = trainPC(:, subset);
%     trainlabels2 = trainlabels(subset);
% 
%     subset=ismember(testlabels, combos(i,:));
%     testPC2 = testPC(:, subset);
%     testlabels2 = testlabels(subset);
%     
%     %Linear Classification
%     pre=classify(testPC2', trainPC2', trainlabels2, 'linear');
%     probs(i) = sum(pre==testlabels2)/length(pre);
% end
% % Calculate best and worst classifications
% [minP, indMin] = min(probs);
% fprintf('The worst classification with LDA was between %i and %i with %.1f%% incorrect matches \n', combos(indMin, 1), combos(indMin, 2), (1-minP)*100);
% [maxP, indMax] = max(probs);
% fprintf('The best classification with LDA was between %i and %i with %.1f%% incorrect matches \n', combos(indMax, 1), combos(indMax, 2), (1-maxP)*100);
% % Plot LDA probabilities
% figure;
% scatter(combos(:,1), combos(:,2), (1-probs)*900, (1-probs), 'filled'), colormap('jet'), colorbar;
% title('Two Digit LGA Classification Error Rates');
% 
% %Set up LDA for 3 digits
% digits = [6 8 9];
% subset=ismember(trainlabels, digits);
% trainPC3 = trainPC(:, subset);
% trainlabels3 = trainlabels(subset);
% 
% subset=ismember(testlabels, digits);
% testPC3 = testPC(:, subset);
% testlabels3 = testlabels(subset);
% 
% %Linear Classification and visualization using first two PC's
% [pre, ~, ~, ~, coeff]=classify(testPC3(1:2,:)', trainPC3(1:2,:)', trainlabels3, 'linear');
% figure, scatter(testPC3(1, :), testPC3(2, :), ones(1,length(testlabels3))*10, testlabels3');
% lim = [-1500 1500 -1500 1500];
% hold on;
% matcoord = [1, 2; 1, 3; 2, 3];
% for i = 1:3
%     K = coeff(matcoord(i,1),matcoord(i,2)).const;
%     L = coeff(matcoord(i,1),matcoord(i,2)).linear;
%     f = @(x,y) K + L(1)*x + L(2)*y;
%     h = fimplicit(f,lim);
%     set(h,'Color','k')
% end
% title('Visualization of LDA Classifier using 2 Principle Components');
% xlabel('Principle Component 1')
% ylabel('Principle Component 2')
% 
% %Three Digit LDA with all PCs
% pre=classify(testPC3', trainPC3', trainlabels3, 'linear');
% threeDigitErr = 1-(sum(pre==testlabels3)/length(pre));
% fprintf('Three digit LDA classification between %i, %i, and %i had an error rate of %.1f%% \n', digits(1), digits(2), digits(3), threeDigitErr);

%LDA 10-digit classifier
pre=classify(testPC', trainPC', trainlabels, 'linear');
ldaErr = 1-(sum(pre==testlabels)/length(pre))

%Decision Tree Classifier
tree=fitctree(trainPC',trainlabels,'CrossVal','on');%'MaxNumSplits',200,
%view(tree.Trained{1},'Mode','graph');
%dtErr = kfoldLoss(tree)
pre = predict(tree.Trained{1}, testPC');
treeErr = 1-(sum(pre==testlabels)/length(pre))

%SVM Classifier
trainPCSVM = trainPC/max(trainPC(:));
testPCSVM = testPC/max(testPC(:));
svm = fitcecoc(trainPCSVM', trainlabels);
pre = predict(svm, testPCSVM');
svmErr = 1-(sum(pre==testlabels)/length(pre))


function out = getPCABasis(in, transform)
    [lx, ly, n] = size(in);
    out = zeros(lx*ly, n);
    for i=1:n
        out(:,i) = reshape(double(in(:,:,i)), lx*ly, 1);
    end
    out = transform'*out;
end