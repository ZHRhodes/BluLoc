/*
 * Global Storage Arrays
 *
 *   Store 5 RSSI values for each of the 15 Beacons
 *   that we have. 5 can be increased to whatever
 *   number we want to improve accuracy in future.
 *
 *   Initialize everything to INT_MIN or whatever
 *   the RSSI for not in range is.
 */

// New values are added to index 0 and old index 4 value is dicarded

int BeaconRSSI [16][5] = {
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN},
    {INT_MIN,INT_MIN,INT_MIN,INT_MIN,INT_MIN}
};

/*
 * States for BLE beacons
 *
 *   NOT_FOUND : -1
 *   FOUND     :  0
 *   JUST_LEFT :  1
 *   NEIGHBOR  :  2
 *
 */

int BeaconState [15] = {
    NOT_FOUND,NOT_FOUND,NOT_FOUND,NOT_FOUND,NOT_FOUND,
    NOT_FOUND,NOT_FOUND,NOT_FOUND,NOT_FOUND,NOT_FOUND,
    NOT_FOUND,NOT_FOUND,NOT_FOUND,NOT_FOUND,NOT_FOUND
};

// Array to indicate if position needs to reset to beacon location
int NeedReset [15] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

// Update RSSI, obtain ID values using Majors/Minors of the Beacons
void updateRSSI(int RSSI [], int ID [])
{
    int temp = 0;
    for (int i=0; i<RSSI.size(); i++)
    {
        BeaconRSSI[ID[i]][4] = BeaconRSSI[ID[i]][3];
        BeaconRSSI[ID[i]][3] = BeaconRSSI[ID[i]][2];
        BeaconRSSI[ID[i]][2] = BeaconRSSI[ID[i]][1];
        BeaconRSSI[ID[i]][1] = BeaconRSSI[ID[i]][0];
        BeaconRSSI[ID[i]][0] = RSSI[i];
    }
}

// Might want to update the following pieces of detecting curve types to suit the experimental data
bool isPeak(int RSSI[5])
{
    if (RSSI[0] < RSSI[1] && RSSI[1] < RSSI[2] && RSSI[2] > RSSI[3] && RSSI[3] > RSSI[4])
        return true;
    else
        return false;
}

bool isIncreasing(int RSSI[5])
{
    if (RSSI[0] > RSSI[1] && RSSI[1] > RSSI[2] && RSSI[2] > RSSI[3] && RSSI[3] > RSSI[4])
        return true;
    else
        return false;
}

bool isDecreasing(int RSSI[5])
{
    if (RSSI[0] < RSSI[1] && RSSI[1] < RSSI[2] && RSSI[2] < RSSI[3] && RSSI[3] < RSSI[4])
        return true;
    else
        return false;
}

/*
 * State Transitions:
 *
 *   NOT_FOUND ----{Beacon Detected}----> FOUND
 *   FOUND     ---{No NEIGHBOR && /\}---> JUST_LEFT
 *   FOUND     -{Neighbor is JUST_LEFT}-> NEIGHBOR
 *   FOUND     --{Beacon Out of Range}--> NOT_FOUND
 *   NEIGHBOR  -----------{/\}----------> JUST_LEFT
 *   NEIGHBOR  -{No JUST_LEFT neighbor}-> FOUND
 *   JUST_LEFT -{Neighbor is JUST_LEFT}-> NEIGHBOR
 */
void updateStates()
{
    bool foundNeighbor = false;
    for (int i=0; i<15; i++)
    {
        if(BeaconState[i]==NEIGHBOR)
        {
            foundNeighbor == true;
            break;
        }
    }

    for (int i=0; i<15; i++)
    {
        switch(BeaconState[i]) {
            case NOT_FOUND:
                if (BeaconRSSI[i][0] != INT_MIN) // Again use whatver the not in range RSSI is
                    BeaconState[i] = FOUND;
            break;

            case FOUND:
                if (!foundNeighbor && isPeak(BeaconRSSI[i])) {
                    BeaconState[i] = JUST_LEFT;
                    NeedReset[i] = 1;
                }
                else if (BeaconRSSI[i][0] == INT_MIN) // Again use whatver the not in range RSSI is
                    BeaconState = NOT_FOUND;
                else if ((i>0 && i<14 && (BeaconState[i+1]==JUST_LEFT || BeaconState[i-1]==JUST_LEFT)) || (i==0 && BeaconState[i+1]==JUST_LEFT) || (i==14 && BeaconState[i-1]==JUST_LEFT))
                    BeaconState[i] = NEIGHBOR;
            break;

            case JUST_LEFT:
                if ((i>0 && i<14 && (BeaconState[i+1]==JUST_LEFT || BeaconState[i-1]==JUST_LEFT)) || (i==0 && BeaconState[i+1]==JUST_LEFT) || (i==14 && BeaconState[i-1]==JUST_LEFT))
                {
                    BeaconState[i] = NEIGHBOR;
                }
                NeedReset[i] = 0;
            break;

            case NEIGHBOR:
                if (isPeak(BeaconRSSI[i])){
                    if (i==14){
                        if (BeaconState[i-1]==JUST_LEFT && isDecreasing(BeaconRSSI[i-1]))
                        {
                            BeaconState[i] = JUST_LEFT;
                            NeedReset[i] = 1;
                        }

                    }
                    else if (i==0){
                        if (BeaconState[i+1]==JUST_LEFT && isDecreasing(BeaconRSSI[i+1]))
                        {
                            BeaconState[i] = JUST_LEFT;
                            NeedReset[i] = 1;
                        }
                    }
                    else if (BeaconState[i-1]==JUST_LEFT && isDecreasing(BeaconRSSI[i-1]))
                    {
                        BeaconState[i] = JUST_LEFT;
                        NeedReset[i] = 1;
                    }
                    else if (BeaconState[i+1]==JUST_LEFT && isDecreasing(BeaconRSSI[i+1]))
                    {
                        BeaconState[i] = JUST_LEFT;
                        NeedReset[i] = 1;
                    }
                }
                else if ((i>0 && i<14 && (BeaconState[i+1]!=JUST_LEFT && BeaconState[i-1]!=JUST_LEFT)) || (i==0 && BeaconState[i+1]!=JUST_LEFT) || (i==14 && BeaconState[i-1]!=JUST_LEFT))
                    BeaconState[i] = FOUND;
            break;
        }
    }
}

