function [Ellipses] = detectEllipses(I)
% RGB �̹����� �޾Ƽ� �� ���ÿ� �ش��ϴ� Ÿ���� �����ϴ� �Լ�
% Ellipses{i}�� Z, A, B, Alpha�� ���� struct (fitellipse �Լ� ����)

%% Set library paths
addpath('fitellipse');

%% Detect dishes

% process edge
[ResizedIm, Segments] = edgeProcessing(I, false);

% fit ellipses
Ellipses = fitEllipses(Segments);

% Ÿ���� Y�� �������� �׿� �ִٰ� �����ϰ� filtering
Ellipses = filterByTilt(Ellipses, 5/180*pi);
Ellipses = filterByMostFrequentX(Ellipses, size(ResizedIm,2) / 10);
Ellipses = filterDoubleLine(Ellipses, size(ResizedIm,1) / 50);

% show image to test
figure;
imshow(ResizedIm);
hold on;
for i = 1 : length(Ellipses)
    Ellipse = Ellipses{i};
    plotellipse(Ellipse.Z, Ellipse.A, Ellipse.B, Ellipse.Alpha, 'r');
end
hold off;

%% Reset added paths
rmpath('fitellipse');

end

%%
function [Inliers] = filterByTilt(Ellipses, Threshold)
% Ÿ���� ������ ������ ���� ���� (radian)

N = length(Ellipses);
Alphas = zeros(1, N);
for i = 1 : N
    Ellipse = Ellipses{i};
    Alphas(i) = Ellipse.Alpha;
end

Inliers = cell(1, 1);
M = 0;
for i = 1 : N
    if abs(Alphas(i) + pi/2) < Threshold
        M = M + 1;
        Inliers{M} = Ellipses{i};
    end
end

end

%%
function [Inliers] = filterByMostFrequentX(Ellipses, Threshold)
% RANSAN�� Y�࿡ ������ ������ ���ؼ��� ����

N = length(Ellipses);
Xs = zeros(1, N);
for i = 1 : N
    Ellipse = Ellipses{i};
    Xs(i) = Ellipse.Z(2);
end

MaxNum = 0;
InliersIDX = [];
for i = 1 : N
    CandidateX = Xs(i);
    IDX = abs(Xs - CandidateX) < Threshold;
    if sum(IDX) > MaxNum
        MaxNum = sum(IDX);
        InliersIDX = IDX;
    end
end

Inliers = cell(1, 1);
M = 0;
for i = 1 : N
    if InliersIDX(i)
        M = M + 1;
        Inliers{M} = Ellipses{i};
    end
end

end

%%
function [Inliers] = filterDoubleLine(Ellipses, Threshold)
% Ÿ���� �Ʒ��� ���� Threshold pixel ���Ϸ� ������ ������ �Ʒ� �͸� ����

N = length(Ellipses);

Y = [];
for i = 1 : N
    Ellipse = Ellipses{i};
    Y = [Y; Ellipse.Z(1) + Ellipse.B];
end

[Y, I] = sort(Y, 'descend');

Inliers = cell(1, 1);
Inliers{1} = Ellipses{I(1)};
M = 1;

for i = 2 : N
    if Y(i - 1) - Y(i) > Threshold
        M = M + 1;
        Inliers{M} = Ellipses{I(i)};
    end
end

end

%%
function [Ellipses] = fitEllipses(Segments)
% �� segment�� ellipse�� fiiting �õ��Ͽ�, fitting �� ellipse�� ����

Ellipses = cell(1, 1);
NumberOfEllipses = 0;
for i = 1 : length(Segments)
    Segment = Segments{i};
    try
        [Z, A, B, Alpha] = fitellipse(Segment, 'linear');
        NumberOfEllipses = NumberOfEllipses + 1;
        Ellipses{NumberOfEllipses}.Z = Z;
        Ellipses{NumberOfEllipses}.A = A;
        Ellipses{NumberOfEllipses}.B = B;
        Ellipses{NumberOfEllipses}.Alpha = Alpha;
    catch
    end
end

end