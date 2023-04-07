global function FFA_Init

struct 
{
    float startTime
    table< string, table< vector, int> > rechedTime

    table< string, array<vector> > checkpoints =
    {
        ["mp_glitch"] = [ <0,0,0> , <100, 0, 0> ] 
    }
    int playersFinished = 0

}file

void function FFA_Init()
{
	ClassicMP_ForceDisableEpilogue( true )
	
    AddCallback_GameStateEnter( eGameState.Playing, SpawnTrigger )
    AddCallback_OnClientConnected( AddDataToFile )

}

void function SpawnTrigger() 
{
    Assert( GetMapName() in file.checkpoints , "map not supported")

    foreach( vector pos in file.checkpoints[GetMapName()])
    {
        entity trigger = CreateEntity( "trigger_cylinder" )
        trigger.SetRadius( TITAN_BUBBLE_SHIELD_INVULNERABILITY_RANGE / 2 )
        trigger.SetAboveHeight( TITAN_BUBBLE_SHIELD_CYLINDER_TRIGGER_HEIGHT / 2 ) //Still not quite a sphere, will see if close enough
        trigger.SetBelowHeight( TITAN_BUBBLE_SHIELD_CYLINDER_TRIGGER_HEIGHT / 2 )
        trigger.SetOrigin( pos )
        DispatchSpawn( trigger )
        PlayFX( FX_HORNET_DEATH, pos )
        thread WaitForPlayer( trigger )
    }

}

void function WaitForPlayer(entity trigger) {

    for(;;){
        table r = trigger.WaitSignal("OnStartTouch")
        entity player =  expect entity(r.activator)

        if(!player.IsPlayer())
            continue


        if( trigger.GetOrigin() in file.rechedTime[player.GetUID()] ){
            Chat_ServerBroadcast( "TRIGGER ALREADY IN FILE")
            continue
        }
            

        file.rechedTime[player.GetUID()] [trigger.GetOrigin()] <- GetUnixTimestamp() 

        foreach( key, value in file.rechedTime[player.GetUID()])
        {
            printt("KEY:    " + key + "      VLAUE: " +value )
        }

        Chat_ServerBroadcast("TRIGGER HAS BEEN REACHED at origin "+ trigger.GetOrigin())
        if(file.rechedTime[player.GetUID()].len() == file.checkpoints[GetMapName()].len())
            file.playersFinished++ 
    }
}

void function AddDataToFile(entity player) 
{
    file.rechedTime[player.GetUID()] <- {}
}