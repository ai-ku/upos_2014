#include <iostream>
#include <vector>
#include <set>
#include <string>
#include <sstream>
#include <limits>
#include "math.h"
#include "stdlib.h"
#include "stdio.h"
#include "clustering.h"


class kmedoids{
public:
     kmedoids();
     kmedoids(int c);
     ~kmedoids();
     std::vector<std::vector<double> > get_data() const { return data;}
     void read();
     void print_info();
     void run(int iter);
private:
     std::vector<std::vector<double> > data;
     int seed;
     std::istream* input;
     clustering *current;     
};
     
kmedoids::kmedoids():seed(10), input(&std::cin) {
     current = new clustering(2);
     srand(seed);
};
kmedoids::kmedoids(int c):seed(0), input(&std::cin) {
     current = new clustering(c);
     srand(seed);
};

kmedoids::~kmedoids(){
     delete current;
};

void kmedoids::read(){
     std::string line, subs;
     while(getline(*input, line)){
          if(line.empty()) continue;
          std::istringstream iss(line);
          if (data.size() % 1000 == 0) std::cerr << ".";          
          std::vector<double> row;
          if (data.size() > 0) row.resize(data[0].size());
          int idx = -1;
          for(int i = 0 ; iss >> subs ; i++){
               if (i == 0){continue;}
               if (i % 2 == 1){ idx = atoi(&subs[0]);}
               if (i % 2 == 0){
                    if(idx >= (int)row.size()) row.resize(idx + 1);
                    row[idx] = atof(&subs[0]);
                    //                    std::cout << "[" << idx << " " << row[idx] << "] ";
                    idx = -1;
               }
          }
          //          std::cout << " " << std::endl;
          //          std::cout << row.size() << std::endl;
          data.push_back(row);
     }
}

void kmedoids::print_info(){
     if (data.size() > 0){
          std::cout << "Data info:[" <<  data.size() << " " << data[0].size() << "]"<<std::endl;
          for(int i = 0 ; i < (int)data.size() ; i++){
               for(int j = 0 ; j < (int)data[i].size() ; j++){
                    std::cout << j<<":"<< data[i][j] << " ";
               }
               std::cout << std::endl;
          }
     }     
     else{
          std::cout << "Empty data" << std::endl;
          exit(1);
     }
}

void kmedoids::run(int iter){
     (*current).random_center(data.size());
     (*current).assign_medoids(data);
     for(int i = 0 ; i < iter; i++){          
          //          (*current).print_info();
          clustering *best = (*current).update_medoids(data);
          if (best == NULL) {
               std::cerr << "No update\n";
               (*current).print_info();
               break;
          }
          else{
               std::cerr << "Update\n";
               delete current;
               current = best;
          }
     }
}

int main(){
     std::cout << "done" << std::endl;
     kmedoids K;
     K.read();
     K.print_info();
     K.run(1000000);
     return 1;
}
