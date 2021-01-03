import WebSocket, {Server} from 'ws';

interface Connection{
    id:number,
    connection: WebSocket
}

class Pool{
    pool: Array<Connection>= []
    anotherpoll:Pool | undefined;
    type:string;
    constructor(type:string){
        this.type = type;
        console.log(type)
    }
    setAnotherPoll(anotherpoll:Pool){
        this.anotherpoll = anotherpoll;
    }
    add(connection:Connection ){
        this.pool.push(connection)
    }
    broadcast(message: string){
        this.pool.forEach(conn => conn.connection.send(message))
    }
    sendToSpecificID(message:string,id:number){
        let conn: Connection|null = null;
        for(let i = 0;i< this.pool.length;i++)
        if(this.pool[i].id == id){
            conn = this.pool[i];
            break;
        }
        if(conn)
        conn.connection.send(message);
    }
    receive(message:string){
        console.log("Messaggio da :"+this.type)
        console.log(message)
        let parsedType = JSON.parse(message).type;
        if(parsedType ==="eval" || parsedType === "update"){
            this.anotherpoll?.broadcast(message);
        }
        
    }
}



const wss = new Server({port:5757});
console.log("partito")
const turtlePoll = new Pool("turtle");
const userPoll = new Pool("user");
turtlePoll.setAnotherPoll(userPoll);
userPoll.setAnotherPoll(turtlePoll);

wss.on('connection',(ws)=>{
    ws.onmessage = (message)=> {
        const parsed = JSON.parse(message.data as string);
        let conn:Connection;

        
        if(parsed.type = "connect")
        switch(parsed.usertype){
            case "turtle":
                console.log("added turtle")
                conn = {id:Math.floor(Math.random()*1000),connection:ws};
                ws.onmessage = ()=>{};
                ws.send(JSON.stringify({type:"eval",command:`setID(${conn.id})`}));
                ws.on("message",(message:string)=>{
                    console.log(message)
                    turtlePoll.receive(message)
                })
                turtlePoll.add(conn);
                break;
            case "user":
                console.log("added user")
                
                conn = {id:Math.floor(Math.random()*1000),connection:ws};
                ws.onmessage = ()=>{};
                ws.on("message",(message:string)=>{
                    console.log(message)
                    userPoll.receive(message)
                })
                userPoll.add(conn);
                break;
        }

    }
    
});