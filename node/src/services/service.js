import { JSDOM } from "jsdom";

const { window } = new JSDOM(`<!DOCTYPE html><body></body>`);
globalThis.window = window;
globalThis.document = window.document;
globalThis.self = globalThis;
Object.defineProperty(globalThis.navigator, "userAgent", {
  value: window.navigator.userAgent,
  configurable: true
});
globalThis.window.addEventListener = () => {};
document.createElement = (tag) => {
  const el = {};
  el.addEventListener = () => {};
  return el;
};


import { spawn } from "child_process";
import path from "path";
import { fileURLToPath } from "url";
import ffmpeg from "fluent-ffmpeg";
import { createCanvas, loadImage } from "canvas";
import { PoseLandmarker, FilesetResolver } from "@mediapipe/tasks-vision";

document.createElement = (tag) => {
  if (tag === "canvas") return createCanvas(1, 1);
  return {};
};

//Route def
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

//R Script def
const scriptPath = path.join(__dirname, "../../../R/script.R");
const rPath = process.env.RSCRIPT_PATH;

//
export default class Service {
  entry = async (data) => {
    this.execMP(data)
    return this.execR(data)
  }
  execMP = async (video) => {
    // 1. Cargar el modelo de MediaPipe
  const vision = await FilesetResolver.forVisionTasks(
    "node_modules/@mediapipe/tasks-vision/wasm"
  );

  //Setea el modelo en modo video
  const poseLandmarker = await PoseLandmarker.createFromOptions(vision, {
    baseOptions: {
      modelAssetPath: "pose_landmarker_full.task", // tu modelo
    },
    runningMode: "VIDEO",
  });

  const videoPath = "../tmp/video.mp4";
  const fps = 1; // framerate que queremos que use el modelo
  let frameIndex = 0;

  ffmpeg(videoPath)
  .format("image2pipe")
  .fps(fps)
  .on("error", (err) => console.error("Error ffmpeg:", err))
  .pipe()
  .on("data", async (chunk) => {
    try {
      // 3. Convertir el frame en imagen usable
      const img = await loadImage(chunk);
      const canvas = createCanvas(img.width, img.height);
      const ctx = canvas.getContext("2d");
      ctx.drawImage(img, 0, 0);
      
      // 4. Procesar el frame en el modelo
      const timestamp = (frameIndex / fps) * 1000; // en ms
      const result = await poseLandmarker.detectForVideo(canvas, timestamp);

      // 5. Usar los datos (ejemplo: log)
      //console.log(`Frame ${frameIndex}`, result.landmarks);

      frameIndex++;
    } catch (err) {
      console.error("Error procesando frame:", err);
    }
  });
  }
  execR = async (matrix) => {
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
      child.stdin.write(JSON.stringify({ matrix }));
      child.stdin.end(); 
    });
    
    //Output
    console.log("R result:", await rCalc);
    return await rCalc
  };
}
