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

  /**
   * Save file to temp directory, so it can be opened with `openFileWithSystem`
   *
   * @param {File} file
   * @return {string} path to temp file or null if errors
   */
  async saveToTemp(file: File): Promise<string> {
    try {
      if (!await this.ionicFile.checkDir(this.ionicFile.cacheDirectory, 'temp')) {
        await this.ionicFile.createDir(this.ionicFile.cacheDirectory, 'temp', false);
      }
      const filename = 'tmp_' + new Date().getTime();
      await this.ionicFile.writeFile(this.ionicFile.cacheDirectory + 'temp/', filename, file);
      return this.ionicFile.cacheDirectory + 'temp/' + filename;
    } catch (e) {
      console.log('Error saving file to temp directory', e);
      return null;
    }
  }

  private async removeTempFiles() {
    try {
      await this.ionicFile.removeRecursively(this.ionicFile.cacheDirectory, 'temp');
    } catch (e) {
    }
  }
