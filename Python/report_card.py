
def get_letter_grade(average_score):
    if average_score >= 90:
        letter_grade = "A"
    elif 80 <= average_score < 90:
        letter_grade = "B"
    elif 70 <= average_score < 80:
        letter_grade = "C"
    elif 60 <= average_score < 70:
        letter_grade = "D"
    else:
        letter_grade = "F"
    return letter_grade

def get_average_score(score1, score2, score3):
    midterm1 = float(score1)
    midterm2 = float(score2)
    final = float(score3)
    average_score = (midterm1 + midterm2 + final) / 3
    return round(average_score, 2)

def parse_grades(file_name):
    grades = []
    with open(file_name, "r") as file_data:
        tsv_file = file_data.readlines()
        for tsv_row in tsv_file:
            student = tsv_row.split('\t')
            last_name = student[0]
            first_name = student[1]
            average_score = get_average_score(student[2], student[3], student[4])
            letter_grade = get_letter_grade(average_score)
            grades.append([last_name, first_name, str(average_score), str(letter_grade)])
    return grades 

if __name__ == "__main__":
    grades = parse_grades("grades.tsv")
    with open("report.txt", "a") as report:
        for grade in grades:
            student = '\t'.join(grade) + '\n'
            report.write(student)