import { spawn } from "child_process";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const scriptPath = path.join(__dirname, "../../../R/script.R");
const rPath = process.env.RSCRIPT_PATH;

export default class Service {
  generic = async (valor) => {
    //MediaPipe

    //R
    let rCalc = new Promise((resolve, reject) => {
      let stdout = "";
      let stderr = "";

      const child = spawn(rPath, [scriptPath]);

      child.stdout.on("data", (data) => {
        stdout += data.toString();
      });

      child.stderr.on("data", (data) => {
        stderr += data.toString();
      });

      child.on("close", (code) => {
        if (code !== 0) return reject(new Error(stderr));
        try {
          const result = JSON.parse(stdout);
          resolve(result);
        } catch (err) {
          reject(err);
        }
      });

      // Enviar datos al stdin de R
      child.stdin.write(JSON.stringify({ valor }));
      child.stdin.end(); 
    });
    
    //Output
    console.log("R result:", await rCalc);
    return await rCalc
  };
}
