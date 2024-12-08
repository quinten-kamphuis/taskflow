const HandleFileUpload = {
    mounted() {
      this.handleUploadComplete();
    },
    updated() {
      this.handleUploadComplete();
    },
    handleUploadComplete() {
      if (this.el.dataset.uploadCompleted === "true") {
        this.pushEventTo(this.el.closest(".phx-component"), "upload_completed", {});
      }
    }
  };
  
  export default HandleFileUpload;