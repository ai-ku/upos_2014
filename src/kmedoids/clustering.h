#include <iostream>
#include <vector>
#include <set>
#include <string>
#include <sstream>
#include <limits>
#include "math.h"
#include "stdlib.h"
#include "stdio.h"
#include <algorithm>


class clustering{
public:
     clustering();
     clustering(int c);
     ~clustering();
     void print_info();
     void random_center(int range);
     double assign_medoids(std::vector<std::vector<double> >& data);
     clustering* update_medoids(std::vector<std::vector<double> >& data);
     std::vector<int> get_assignment(std::vector<std::vector<double> >& data);
     void set_centroids(std::vector<int> init);
     std::vector<std::vector<int>> medoids;
     std::vector<int> centroids;
     std::vector<double> clusterErr;
     int cluster;
     double totalErr;
};

