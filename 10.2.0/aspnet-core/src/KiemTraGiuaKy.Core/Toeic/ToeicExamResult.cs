using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;
using KiemTraGiuaKy.Authorization.Users;

namespace KiemTraGiuaKy.Toeic;

[Table("ToeicExamResults")]
public class ToeicExamResult : FullAuditedEntity<int>
{
    public int ExamId { get; set; }

    [ForeignKey(nameof(ExamId))]
    public virtual ToeicExam Exam { get; set; }

    public long? UserId { get; set; }

    [ForeignKey(nameof(UserId))]
    public virtual User User { get; set; }

    public int Score { get; set; } // 0 -> 495

    public int MaxScore { get; set; } = 495;

    [MaxLength(50)]
    public string CefrLevel { get; set; } // CEFR B2, B1...

    public int TotalCorrect { get; set; }

    public int TotalIncorrect { get; set; }

    public int TotalSkipped { get; set; }

    public int TimeTakenSeconds { get; set; }

    [MaxLength(1000)]
    public string AiFeedback { get; set; }
}
