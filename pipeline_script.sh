#!/bin/bash
set -e
echo "Welcome to ODM docker."
PICTURE_SOURCE_DIR=$1
RESULT_DIR=$2
MODEL_PATH=$3
MODEL_PYTHON_PATH=$4

# Change directory to result directory
cd $RESULT_DIR

#Create results folder
mkdir -p "working_dir"
mkdir -p "results"
mkdir -p "working_dir/images"
#Copy input images into folder called "images" to safecase docker
cp -R "$PICTURE_SOURCE_DIR/." "working_dir/images"
# Create output folders for temp docker results 
# -p options to avoid errors if folders are already existing
mkdir -p "working_dir/odm_orthophoto"
mkdir -p "working_dir/odm_georeferencing"
mkdir -p "working_dir/odm_meshing"
mkdir -p "working_dir/odm_texturing"

docker run -it --rm -v "$RESULT_DIR/working_dir/images:/code/images" -v "$RESULT_DIR/working_dir/odm_georeferencing:/code/odm_georeferencing" -v "$RESULT_DIR/working_dir/odm_meshing:/code/odm_meshing"  -v "$RESULT_DIR/working_dir/odm_orthophoto:/code/odm_orthophoto" -v "$RESULT_DIR/working_dir/odm_texturing:/code/odm_texturing" opendronemap/odm

echo "ODM Docker finished.Forward results to QGIS for further processing."

#Create folder for odm_orthophoto forwarding and copy orthophoto into it
mkdir -p "results/odm_orthophoto"
cp -r "working_dir/odm_orthophoto/odm_orthophoto.tif" "results/odm_orthophoto/"

CURRENT_DATE_TIME=$( date '+%F_%H:%M:%S' )
mkdir "results/$CURRENT_DATE_TIME"

mv -i "working_dir/odm_orthophoto" "results/$CURRENT_DATE_TIME"
mv -i "working_dir/odm_georeferencing" "results/$CURRENT_DATE_TIME"
mv -i "working_dir/odm_meshing" "results/$CURRENT_DATE_TIME"
mv -i "working_dir/odm_texturing" "results/$CURRENT_DATE_TIME"

rm -R "working_dir"

mkdir "results/QGIS"

cp "results/odm_orthophoto/odm_orthophoto.tif" "results/QGIS/Ortho-DroneMapper.tif"
cp  $MODEL_PYTHON_PATH "results/QGIS/"

cd "results/QGIS"

mkdir "models"

cp $MODEL_PATH "models/"

# Without docker hub, pull from nuest docker github repo
# wget https://github.com/nuest/docker-qgis-model/archive/master.zip
# unzip master.zip
# rm -R master.zip
# cp -R docker-qgis-model-master/ubuntu $PWD
# rm -R docker-qgis-model
# docker build -t docker-qgis-model:trusty -f ubuntu/trusty/Dockerfile ubuntu/.
# docker run --rm -it -v $PWD/:/workspace qgis-model-ubuntu:trusty
mkdir -p "QGIS_results"

docker run --name qgis_example_hub -v $PWD/:/workspace nuest/docker-qgis-model:trusty
docker cp qgis_example_hub:/workspace/results QGIS_results
tree QGIS_results
docker rm qgis_example_hub