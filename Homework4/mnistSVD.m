clear all, close all;

%Collect images/labels and randomly sample first nsample images
[images, labels] = mnist_parse('train-images.idx3-ubyte', 'train-labels.idx1-ubyte');
[lx, ly, n] = size(images);
nsample = 60000;
sample = randperm(n);
sample = sample(1:nsample);

% Reshape images to make data matrix and run SVD
A = zeros(lx*ly, nsample);
for i=1:nsample
    ind = sample(i);
    A(:,i) = reshape(double(images(:,:,ind)), lx*ly, 1);
end
[U, S, V] = svd(A, 'econ');
s=diag(S);

%Plot Singular Values and eigen-images for the first 12 features
plot(s(1:12), 'ro');
axis([1, 12, 0, max(s)+1])
figure;
for i=1:12
    pc = U(:,i)*255/max(U(:,i));
    im = uint8(reshape(pc, lx, ly));
    subplot(3,4,i), imshow(im), title(['Feature #', num2str(i)]);
end

%Extract [features] principle components
features = 2:11;
svPC = S*V';
svPC = svPC(features, :);
uPC = U(:,features);
imgPC = uPC*svPC;

%Show rank given different principle components
figure;
rank=[3, 5, 8, 10, 784];
for i=1:length(rank)
    im = uint8(reshape(U(:,1:rank(i))*S(1:rank(i),:)*(V(1,:)'), lx, ly));
    subplot(1,5,i), imshow(im), title(['First ', num2str(rank(i)), ' PCs']);
end
title('Full Image');

%3D plot showing projection on principle components of each number
components = [2 3 5];
C = labels(sample);
sublist = 1:nsample;
sublist = ((C==2|C==4)); %To select certain number values for visualization
X = V(sublist, components(1));
Y = V(sublist, components(2));
Z = V(sublist, components(3));
Sz = ones(length(X), 1)*10;
C = C(sublist);
figure;
scatter3(X,Y,Z,Sz,C), colormap('jet'), colorbar;
title('Projection of data onto 3 principle components');
xlabel(['Component ', num2str(components(1))]);
ylabel(['Component ', num2str(components(2))]);
zlabel(['Component ', num2str(components(3))]);

save('pcaMats', 'U','S','V','uPC', 'svPC')