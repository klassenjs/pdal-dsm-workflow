while (true) ; do echo $(date) $(squeue | wc -l); sleep 60; done | tee -a squeue.log

