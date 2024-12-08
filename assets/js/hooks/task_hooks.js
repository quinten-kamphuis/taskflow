let DragSource = {
  mounted() {
    this.el.addEventListener("dragstart", e => {
      if (!e.target.matches('[data-task-id]')) {
        e.preventDefault();
        return;
      }

      const taskId = e.target.dataset.taskId;
      if (!taskId) {
        e.preventDefault();
        return;
      }

      e.dataTransfer.setData("text/plain", taskId);
      e.target.classList.add("opacity-50");
    });

    this.el.addEventListener("dragend", e => {
      if (e.target.matches('[data-task-id]')) {
        e.target.classList.remove("opacity-50");
      }
    });
  }
}

let DropTarget = {
  mounted() {
    this.el.addEventListener("dragover", e => {
      e.preventDefault();
      this.el.classList.add("bg-gray-100");
    });

    this.el.addEventListener("dragleave", e => {
      this.el.classList.remove("bg-gray-100");
    });

    this.el.addEventListener("drop", e => {
      e.preventDefault();
      this.el.classList.remove("bg-gray-100");
      
      const taskId = e.dataTransfer.getData("text/plain");
      // Validate that we have a valid task ID
      if (!taskId || taskId.trim() === "") {
        return;
      }

      const newStatus = this.el.dataset.status;
      if (!newStatus) {
        return;
      }
      
      this.pushEvent("update_task_status", {
        task_id: taskId,
        status: newStatus
      });
    });
  }
}

export default { DragSource, DropTarget }