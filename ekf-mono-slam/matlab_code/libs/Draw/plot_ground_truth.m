filename = 'Bicocca_2009-02-27a-GROUNDTRUTH.dat';
M = csvread(filename);

plot(M(:,2),M(:,3), 'g', 'LineWidth', 2)
grid on
xlabel('X Position')
ylabel('Z Position')