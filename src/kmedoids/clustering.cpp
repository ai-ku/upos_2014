#include "clustering.h"

clustering::clustering(): cluster(2), totalErr(0){
     medoids.resize(cluster);
     clusterErr.resize(cluster,0);
}

clustering::clustering(int c): cluster(c), totalErr(0){
     medoids.resize(cluster);
     clusterErr.resize(cluster,0);
}

clustering::~clustering(){}

void clustering::print_info(){
     std::cout << "medoids\n";
     for(int i = 0 ; i  <(int)medoids.size(); i++){
          std::cout << "c:" << centroids[i] << " => ";
          for(int j = 0 ; j  <(int)medoids[i].size(); j++){                    
                    std::cout << medoids[i][j] << " ";
          }
          std::cout << " cluster_err:" << clusterErr[i] <<std::endl;
     }
     std::cout << "TotalErr:" << totalErr << std::endl;
}

void clustering::random_center(int range){
     std::cerr << "Initializing random centers\n";
     std::set<int> centers;
     //     centers.insert({1, 7});
     while((int)centers.size() < cluster)
          centers.insert(rand() % range);
     std::copy(centers.begin(), centers.end(), std::back_inserter(centroids));
     // for( auto it = centroids.begin() ; it != centroids.end(); it++){
     //      std::cout <<*it << " ";
     // }
     // std::cout << std::endl;
}

void clustering::set_centroids(std::vector<int> init){
     std::copy(init.begin(), init.end(), std::back_inserter(centroids));
}

double clustering::assign_medoids(std::vector<std::vector<double> >& data){
     totalErr = 0;
     for(int i = 0 ; i < (int)data.size(); i++){
          double min = std::numeric_limits<int>::max();
          int mini = -1;
          for( int c = 0 ; c < (int)centroids.size(); c++){
               if(centroids[c] == i){
                    min = 0;
                    mini = c;
                    break;
               }
               else if (data[i][centroids[c]] < min){
                    min = data[i][centroids[c]];
                    mini = c;
               }               
          }
          if(centroids[mini] != i){
               medoids[mini].push_back(i);
               clusterErr[mini] += min;
               totalErr += min;
          }
     }
     return totalErr;
}

std::vector<int> clustering::get_assignment(std::vector<std::vector<double> >& data){
     std::vector<int> assignment(data.size(),-1);
     for(int i = 0 ; i < (int) data.size(); i++){
          for( int m = 0 ; m < (int)medoids.size(); m++){
               for( int p = 0 ; p < (int)medoids[m].size(); p++){
                    assignment[medoids[m][p]] = m;
               }
          }          
     }
     return assignment;
}

clustering * clustering::update_medoids(std::vector<std::vector<double> >& data){
     clustering * best = NULL;
     for( int m = 0 ; m < (int)medoids.size(); m++){
          // exchange centroid[m] with medoid[m][p]
          for( int p = 0 ; p < (int)medoids[m].size(); p++){
               std::swap(centroids[m], medoids[m][p]);
               clustering *t = new clustering(cluster);
               (*t).set_centroids(centroids);
               double error = (*t).assign_medoids(data);
               //               std::cout << centroids[m] << " err:"<< error << std::endl;
               if (error < totalErr){
                    //                    std::cout << "best" << std::endl;
                    best = t;
                    //                    (*best).print_info();
               }
               else{
                    std::swap(centroids[m], medoids[m][p]);
                    delete t;
               }
          }
          //          std::cout << "F:" << centroids[m] << " " << clusterErr[m] << std::endl;          
     }
     return best;
}
