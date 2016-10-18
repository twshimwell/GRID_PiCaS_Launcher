#=========
#Updates the status of the token from a shell script or another python script
#
#=========

import couchdb
import os,sys,time,subprocess
from update_token_status import update_status

start=0
def progress_loop(db="",uname="",pwd="",tok_id,outfile='ouptput',parset="Pre-Facet-Calibrator.parset"):
    '''
        Loops while generic pipeline is running and updates the token status to the current
        step running and the timestamp of the step start. It gets the step name from the generic
	pipeline output where it's recorded upon step launch
    '''
    #Get the number of steps from the parset and update progress % (+1 for downloading)

    p=subprocess.Popen(['pgrep','-u',os.environ["USER"],'-f','genericpipeline.py'],stdout=subprocess.PIPE)
    running=p.communicate()[0]
    finished_steps=[]
    print start
    while len(running)>0 or time.time()-start<60:
        time.sleep(5)
        steps=get_steps(outfile)
        for st in steps:
            if st not in finished_steps:#finished steps is updated every iteration of the loop so the times aren't doublecounted
                update_status(db,uname,pwd,tok_id,st)
        p=subprocess.Popen(['pgrep','-u',os.environ["USER"],'-f','genericpipeline.py'],stdout=subprocess.PIPE)
        running=p.communicate()[0]
        finished_steps=steps



def get_steps(outfile='output'):
    p_grep=subprocess.Popen(['grep','Launching',outfile],stdout=subprocess.PIPE)
    grep_results=p_grep.communicate()[0].split('\n')
    results=[]
    for line in grep_results:
        if len(line)>2:
            results.append(line.split()[-1]) #contains all the step names formatted properly
    return results

if __name__ == '__main__':
    start=time.time()
    progress_loop(sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4],sys.argv[5],sys.argv[6])
