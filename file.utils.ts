export function convertDataUrlToFile(dataUrl: string, name: string): Promise<File> {
  return fetch(dataUrl)
    .then(res => res.blob())
    .then(blob => new File([blob], name, {type: blob.type}));
}

export function convertFileToDataUrl(file: File): Promise<string> {
  return new Promise<string>((resolve) => {
    const reader = new FileReader();
    reader.addEventListener('load', (e) => {
      resolve(reader.result.toString());
    });
    reader.readAsDataURL(file);
  });
}
