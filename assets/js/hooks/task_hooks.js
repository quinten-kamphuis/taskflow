let DragSource = {
    mounted() {
      this.el.addEventListener("dragstart", e => {
        e.dataTransfer.setData("text/plain", e.target.id)
        e.target.classList.add("opacity-50")
      })
  
      this.el.addEventListener("dragend", e => {
        e.target.classList.remove("opacity-50")
      })
    }
  }
  
  let DropTarget = {
    mounted() {
      this.el.addEventListener("dragover", e => {
        e.preventDefault()
        this.el.classList.add("bg-gray-100")
      })
  
      this.el.addEventListener("dragleave", e => {
        this.el.classList.remove("bg-gray-100")
      })
  
      this.el.addEventListener("drop", e => {
        e.preventDefault()
        this.el.classList.remove("bg-gray-100")
        
        const taskId = e.dataTransfer.getData("text/plain").replace("task-", "")
        const newStatus = this.el.dataset.status
        
        this.pushEvent("update_task_status", {
          task_id: taskId,
          status: newStatus
        })
      })
    }
  }
  
  export default { DragSource, DropTarget }