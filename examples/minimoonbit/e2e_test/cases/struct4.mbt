// 结构体测试4：结构体数组
struct Student {
  id: Int;
  score: Int;
}

fn find_max_score(students: Array[Student], n: Int) -> Int {
  let mut max_score = students[0].score;
  let mut i = 1;
  while i < n {
    if students[i].score > max_score {
      max_score = students[i].score;
    };
    i = i + 1;
  }
  max_score
}

fn average_score(students: Array[Student], n: Int) -> Int {
  let mut sum = 0;
  let mut i = 0;
  while i < n {
    sum = sum + students[i].score;
    i = i + 1;
  }
  sum / n
}

fn main {
  let s1 = Student::{ id: 1, score: 85 };
  let s2 = Student::{ id: 2, score: 92 };
  let s3 = Student::{ id: 3, score: 78 };
  let s4 = Student::{ id: 4, score: 95 };
  let s5 = Student::{ id: 5, score: 88 };
  
  let students = [s1, s2, s3, s4, s5];
  
  println(find_max_score(students, 5));
  println(average_score(students, 5));
}

