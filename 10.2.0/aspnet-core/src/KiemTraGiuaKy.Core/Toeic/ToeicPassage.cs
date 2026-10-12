using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;

namespace KiemTraGiuaKy.Toeic;

[Table("ToeicPassages")]
public class ToeicPassage : FullAuditedEntity<int>
{
    public int ExamId { get; set; }

    [ForeignKey(nameof(ExamId))]
    public virtual ToeicExam Exam { get; set; }

    [MaxLength(100)]
    public string DocumentType { get; set; } // Corporate Notice, Email, Article...

    [MaxLength(200)]
    public string Title { get; set; }

    [MaxLength(200)]
    public string Recipient { get; set; }

    [MaxLength(200)]
    public string Sender { get; set; }

    [MaxLength(100)]
    public string Date { get; set; }

    [MaxLength(250)]
    public string Subject { get; set; }

    [Required]
    public string Content { get; set; }

    public virtual ICollection<ToeicQuestion> Questions { get; set; } = new List<ToeicQuestion>();
}
