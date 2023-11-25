#!/work/u00cjz00/binary/bash5.0/bin/bash
#SBATCH -A MST110386                                                    ### project number, Example MST109178
#SBATCH -J _t2lora                                                      ### Job name, Exmaple jupyterlab
#SBATCH -p gp4d                                                         ### Partition Name, Example ngs1gpu
#SBATCH --nodes=1                                                       ### Nodes, Default 1, node number
#SBATCH --ntasks-per-node=1                                             ### Tasks, Default 1, per node tasks
#SBATCH -c 4                                                            ### Cores assigned to each task, Example 4
#SBATCH --gres=gpu:1                                                    ### GPU number, Example gpu:1
#SBATCH --time=0-1:00:00                                                ### Runnung time, days-hours:minutes:seconds or hours:minutes:seconds
#SBATCH -o genai_%j.out                                                 ### Log folder, Here %j is job ID
#SBATCH -e genai_%j.err                                                 ### Log folder, Here %j is job ID


### 0. pipi install libsray savefolder
saveFolder=home

### 1. IMAGE
IMAGE=/work/u00cjz00/nvidia/pytorch_2.1.0-cuda11.8-cudnn8-devel.sif
IMAGE_basename=S_${saveFolder}_$(basename "$IMAGE" .sif)

### 2. VIRTUAL LIBRARY and BINARY FOLDER
libraryFolder=/${saveFolder}/$(whoami)/libraryFolder/${IMAGE_basename}/local/lib
libraryFolder_binding=${libraryFolder}:${HOME}/.local/lib
binFolder=/${saveFolder}/$(whoami)/libraryFolder/${IMAGE_basename}/local/bin
binFolder_binding=${binFolder}:${HOME}/.local/bin


# 3. SINGULARITY
ml libs/singularity/3.10.2
singularity exec --nv -B /work -B ${libraryFolder_binding} -B ${binFolder_binding} ${IMAGE} \
bash -c "export PATH=$PATH:$HOME/.local/bin:/work/u00cjz00/os/ubuntu/bin; chainlit --help; sleep 30" &
pid0=$!

# 4. Computing NODE
noed_hostname=$(hostname -s)
noed_port=$(python3 /work/u00cjz00/binary/availablePort.py)
node_ip=$(cat /etc/hosts |grep "$(hostname -a)" | awk '{print $1}')

# 5. Output message
echo ""
echo ""
echo "****************************** 請輸入下方指令 ******************************"
echo ""
echo "# STEP1: Execute cmd in your client below to login login_node"
echo ssh $(whoami)@ln01.twcc.ai
echo ""
echo "# STEP2: Login  computing_node "
echo ssh ${noed_hostname}
echo ""
echo ""
echo "***********************************************************************************************"

## 6. Get pid
pid0=$!
sleep 2
pid1=$(pgrep -P ${pid0})
pid=${pid1}
echo "PID0:${pid0} , PID:${pid1}"

## 7. WAIT JOB
wait $pid0

