import strutils
import strformat
import db_sqlite

type
  Task* = object
    id:int
    name:string
    description:string
    done:bool

proc init*() =
  let db = open("tasks.db","","","")
  defer:
    db.close()

  # language=SQL
  let cmd = sql"""
    CREATE TABLE IF NOT EXISTS task(
      id          INTEGER PRIMARY KEY,
      name        TEXT    NOT NULL,
      description TEXT    NOT NULL,
      done        BOOLEAN NOT NULL
    )
    """
  discard db.tryExec(cmd)

proc create*(name:string, description: string, done:bool = true): Task =
  let db = open("tasks.db", "", "", "")
  let id = db.tryInsertID(sql"INSERT INTO task (name, description, done) VALUES (?, ?, ?)", name, description, done)
  db.close()

  echo fmt"タスク「{name}」を登録しました！"

  result = Task(
  name:name,
  description: description,
  done: done
  )

proc index*(): seq[Task] =
  let db = open("tasks.db", "", "", "")
  let tasks = db.getAllRows(sql"SELECT id, name, description, done FROM task")
  result = @[]
  for task in tasks:
    result.add(
      Task(
        id: task[0].parseInt,
        name: task[1],
        description: task[2],
        done: task[3].parseBool
      )
    )

proc show*(id: int): Task =
  let db = open("tasks.db", "", "", "")
  let task = db.getRow(sql"SELECT id, name, description, done FROM task WHERE id = ?", id)
  result = Task(
    id: task[0].parseInt,
    name: task[1],
    description: task[2],
    done: task[3].parseBool
  )

proc update*(task: Task):Task =
  let db = open("tasks.db", "", "", "")
  db.exec(
    sql"UPDATE task SET name = ?, description = ?, done = ? WHERE id = ?",
    task.name,
    task.description,
    task.done,
    task.id
  )

  echo fmt"タスク「{task.name}」を更新しました！"

  result = task

proc destroy*(id: int): Task =
  let db = open("tasks.db", "", "", "")
  let task = db.getRow(sql"SELECT id, name, description, done FROM task WHERE id = ?", id)
  db.exec(sql"DELETEE FROM task WHERE id = ?", id)

  let name = task[1]
  echo fmt"タスク「{name}」を削除しました！"

  result = Task(
    id: task[0].parseInt,
    name: name,
    description: task[2],
    done: task[3].parseBool
  )
