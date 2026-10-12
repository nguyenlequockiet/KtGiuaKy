using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;

namespace KiemTraGiuaKy.Toeic;

[Table("ToeicQuestions")]
public class ToeicQuestion : FullAuditedEntity<int>
{
    public int ExamId { get; set; }

    [ForeignKey(nameof(ExamId))]
    public virtual ToeicExam Exam { get; set; }

    public int? PassageId { get; set; }

    [ForeignKey(nameof(PassageId))]
    public virtual ToeicPassage Passage { get; set; }

    public int PartNumber { get; set; } // 5, 6, 7

    public int QuestionNumber { get; set; } // 101 -> 200

    [MaxLength(100)]
    public string CategoryName { get; set; } // Từ vựng & Ngữ pháp, Đọc hiểu...

    [Required]
    public string Prompt { get; set; }

    [MaxLength(10)]
    public string CorrectAnswer { get; set; } // A, B, C, D

    public string Explanation { get; set; }

    public virtual ICollection<ToeicAnswerChoice> Choices { get; set; } = new List<ToeicAnswerChoice>();
}
