using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Abp.Domain.Entities.Auditing;

namespace KiemTraGiuaKy.Toeic;

[Table("ToeicExams")]
public class ToeicExam : FullAuditedEntity<int>
{
    [Required]
    [MaxLength(50)]
    public string Code { get; set; }

    [Required]
    [MaxLength(200)]
    public string Title { get; set; }

    [MaxLength(500)]
    public string Description { get; set; }

    [MaxLength(50)]
    public string Category { get; set; } // Full, Part5, Part6, Part7

    public int DurationMinutes { get; set; } = 75;

    public int TotalQuestions { get; set; } = 100;

    [MaxLength(50)]
    public string Difficulty { get; set; }

    public bool IsActive { get; set; } = true;

    public virtual ICollection<ToeicPassage> Passages { get; set; } = new List<ToeicPassage>();

    public virtual ICollection<ToeicQuestion> Questions { get; set; } = new List<ToeicQuestion>();
}
