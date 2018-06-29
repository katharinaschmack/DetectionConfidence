
perf=.5:.01:1;
for k=1:length(perf)
deltaR(k)=(1-(perf(k)^2))/perf(k)^2;
end

%d
a=[.5488 0.7393 .8415 1 1.3];
b=[80.35 75.83 73.69 70.71 65.95];
figure
plot(a,b,'-.','MarkerSize',10);
hold on
plot(deltaR,perf*100,'rx','MarkerSize',10)
