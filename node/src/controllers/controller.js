import {Router} from 'express';
import Service from '../services/service.js';

const router = Router();
const svc = new Service();

router.post('/', async (req, res) => {
    let respuesta;
    console.log("Controller: POST / with body:", req.body);
    //let returnJson = await svc.entry(req.body);
    if( returnJson!= null)
    {
        respuesta = res.status(200).json(returnJson);
    } 
    else
    {
        respuesta = res.status(500).send(`Error interno.`)
    }
    return respuesta;
});

export default router; 