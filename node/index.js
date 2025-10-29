import express from "express"; 
import cors from "cors"; 
import router from "./src/controllers/controller.js";


const app = express(); 
const port = 3002; //(http://localhost:3002) 

//Middlewares 
app.use(cors());  
app.use(express.json({limit: '50mb'}));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));



app.use("/api/",router);

app.listen(port,()=>
{
    console.log(`listening on port ${port}`) 
})

