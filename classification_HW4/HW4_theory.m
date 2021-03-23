clc; clear;

%%
I = [1 2 5 0; 2 2 4 1; 2 2 5 1; 1 1 1 1];
W = zeros(16, 16);
% Calculate weight matrix
cur_row = 1;
for i = 1:4
    for j = 1:4
        cur_coord = I(i,j);
        cur_col = 1;
        % Compute weight for each coordinate to current coordinate
        for x = 1:4
            for y = 1:4
                value = -((I(i,j) - I(x,y))^2 + (i-x)^2 + (j-y)^2);
                if value ~= 0
                    W(cur_row,cur_col) = exp(value);
                else
                    W(cur_row,cur_col) = 0;
                end
                cur_col = cur_col + 1;
            end
        end
        cur_row = cur_row + 1;
    end
end

% Calculate and create diagonal matrix
W
sum(W);
D = diag(sum(W))


[U, S, V] = svd(D-W);
S % Eigenvalues
U(:,end-1) % Eigenvector
