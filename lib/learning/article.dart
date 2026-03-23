// models/article.dart
class Article {
  final String title;
  final String content;
  final String? linkUrl; // Optional external link
  final List<String> bottomImages; // Images to show at bottom of article

  const Article({
    required this.title,
    required this.content,
    this.linkUrl,
    this.bottomImages = const [],
  });
}

// Updated article data with link and bottom images
final List<Article> articlesData = [
  Article(
    title: 'How Humans See Color',
    content: '''
Color plays an important role in our daily lives—it helps us recognize objects, affects our emotions, and even influences our choices. Surprisingly, objects themselves do not actually have color. Instead, color is created by the way light interacts with objects and how our eyes and brain interpret that light.

Humans can see a specific range of light called the visible spectrum, which lies between ultraviolet and red light. Scientists estimate that the human eye can distinguish up to 10 million different colors within this range.

When light hits an object, such as a lemon, the object absorbs some wavelengths of light and reflects others. The reflected light enters the eye through the cornea, which bends the light toward the pupil. The pupil controls how much light enters, while the lens focuses the light onto the retina at the back of the eye.

The retina contains two types of light-sensitive cells called photoreceptors: rods and cones. Rods help us see in dim or low light, but they do not detect color. Cones, on the other hand, work best in bright light and are responsible for color vision. Most people have about 6 million cones and 110 million rods.

There are three types of cones, each sensitive to different wavelengths of light—red, green, and blue. When reflected light stimulates these cones, they send signals through the optic nerve to the brain's visual cortex. The brain processes these signals and interprets them as specific colors. For example, when both red and green cones are activated by reflected light from a lemon, the brain perceives the color yellow.

In low-light conditions, only the rods are activated, which is why we see shades of gray instead of color. Our perception of color is also influenced by past experiences, a process known as color constancy. This allows us to recognize an object's color as consistent even under different lighting conditions.

To learn more about how humans see color, you can read the full article from the American Academy of Ophthalmology at:
''',
    linkUrl:
        'https://www.aao.org/eye-health/tips-prevention/how-humans-see-in-color',
    bottomImages: [
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXf-Bh7ftFligr6OwdfUdRr305fHhvSSime6ZxvjMLgYE96RWYV142zH04g0-OxmbcBetE3hBctd08zs_WA4VLbOH_FWt4sRAlwxYn47-6yxrmEJsoXaPltG1VTgboPi8ONWQgbp1Q=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXeB0emHlk6grjJiGDY6xK8aRQkN4sSwmoOW2ME4Tgi0lwOpSFRnsC9HpUpEmjVpfMxgzXiOsvgOrbuPj1gn8ibrnlR9f8M8NsHDIkjOyUPwpn5cS9PJ6cUi0qYFS6FACUeDjJAfOQ=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
    ],
  ),
  Article(
    title: 'Understanding Color Vision Deficiency',
    content: '''
Color vision deficiency is a condition that affects a person’s ability to distinguish certain shades of color. It is often called “color blindness,” although complete color blindness is very rare. Most people with this condition can still see colors but may have difficulty telling some colors apart.

Color vision depends on specialized cells in the retina called cones. These cones are located mainly in the macula, the central part of the retina, and contain light-sensitive pigments. Each cone responds to one of three types of light: red, green, or blue. Together, these cones send signals to the brain through the optic nerve, allowing us to perceive a wide range of colors. When one or more types of cones do not function properly, color vision deficiency occurs.

The most common type of color vision deficiency is red-green deficiency. People with this condition do not completely lose the ability to see red or green, but they may struggle to tell the two colors apart, especially when the colors are very light or dark. Another, less common type is blue-yellow deficiency, which is usually more severe. In some cases, people may see colors as dull, neutral, or gray. A very rare condition called achromatopsia causes total color deficiency, where a person sees only black, white, and shades of gray.

Color vision deficiency is usually inherited and often affects both eyes. It is more common in males than females due to genetics. However, it can also be caused by eye injuries, diseases, medications, aging, or chemical exposure. Conditions such as diabetes, glaucoma, macular degeneration, and neurological diseases may also affect color vision.

Many people are unaware they have color vision deficiency because they learn to associate certain colors with objects over time. Early detection is important, especially for children, since many learning materials rely on color. Diagnosis is done through eye exams using special color plate tests. While there is no cure for inherited color vision deficiency, people can adapt through strategies such as organizing items by position instead of color or using tinted lenses to improve color distinction.

For more detailed information about color vision deficiency, you can read the full article from the American Optometric Association at:
''',
    linkUrl:
        'https://www.aoa.org/healthy-eyes/eye-and-vision-conditions/color-vision-deficiency',
    bottomImages: [
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXf40_ywURpWn0WgKDtSQyaAW3t2E69dxP0sipCy6CWaG04GIKBMwLiZsucqrctjG--pCUkKWfim2jaXt0C6CP4fHARcr1I4fpfu7gzuvA887URzzNXuY3sYQsYJ_FBuLRhiEQKJSg=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
    ],
  ),
  Article(
    title: 'Types of Color Blindness',
    content: '''
Color blindness, also known as color vision deficiency, occurs when the cone cells in the retina do not function normally. Cone cells are responsible for detecting red, green, and blue light, which the brain combines to create the full range of colors we see. When one or more types of cones are missing or not working correctly, a person may have difficulty distinguishing certain colors.

People with normal color vision are called trichromats, meaning all three types of cone cells function properly. However, not everyone has fully normal color vision.

One common variation is anomalous trichromacy, where all three cone types are present, but one does not respond correctly to light. This results in partial color blindness. The most common form is deuteranomaly, which affects sensitivity to green light. Protanomaly affects red light sensitivity, while tritanomaly, which affects blue light, is extremely rare. People with anomalous trichromacy may confuse colors such as red, green, brown, orange, blue, and purple, especially under poor lighting conditions.

A more severe form of color blindness is dichromacy, where one type of cone cell is completely absent. This means a portion of the color spectrum cannot be seen at all. There are three types of dichromacy: protanopia (no red perception), deuteranopia (no green perception), and tritanopia (no blue perception). Individuals with red or green deficiencies often confuse reds, greens, browns, and oranges, while blues and yellows tend to stand out more clearly.

The rarest form of color blindness is monochromacy, also known as achromatopsia. People with this condition cannot perceive color at all and see the world only in shades of black, white, and gray. Achromatopsia is extremely rare and often comes with additional visual challenges, such as light sensitivity.

Color blindness is usually inherited and affects more men than women. Worldwide, about 8% of men and 0.5% of women have a red–green color vision deficiency. The severity can range from mild to severe, and while most people adapt well, accurate diagnosis is important so appropriate support can be provided.

To learn more about the different types of color blindness, you can read the full article from Color Blind Awareness at:
''',
    linkUrl:
        'https://www.colourblindawareness.org/colour-blindness/types-of-colour-blindness/',
    bottomImages: [
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXda7tdsdf7SfVt2Ggpf0KRR-urMILwzyf0qZbXwzTZfzb6oZ7vzzYzJfLi_FfH-YnPir-z4hRmGI5HI8wbP4--mDO39YcWZ8KaR-1zDt45p34dKZK7Syu6eHYsLHkTR-KKZpr71=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXfPEzj5Jpcu4Xr-I2hlrXgT9Tx4H4rWzc5KvuNMppHZGli6W1RJhueZAI_lU6axtI6QPmhguNl94csNV-neqM_JUlynkzgopb7XxF3WbXPY4khgOIq3ULFP7CdkpHI0u-OOyVvc6g=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXc-BnaxbH295CDjzXhp7m66fF3-GUi0VMQrc0RihyqN_zJ9KhIkk_9bjvGxn6d2Q6AAjGDPdNSCjP4rmEfxfsbIgIoUaKgsiK0Ep1V3Y_ttzpMFyw3uW3m6s8e18oLKwdAprb5nDQ=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
    ],
  ),
  Article(
    title: 'Living with Color Vision Deficiency',
    content: '''
Living with color vision deficiency can present many everyday challenges that people with normal color vision may not notice. Simple activities such as choosing clothes, cooking food, gardening, driving, or using everyday technology can become difficult when colors are hard to distinguish. In some cases, color vision deficiency can even lead to safety issues, such as misreading warning lights or failing to notice sunburn.

Food preparation is a common challenge. Many people with red–green color vision deficiency struggle to tell whether meat is cooked properly or whether fruits like bananas and tomatoes are ripe. Some foods may even appear unappealing because their colors look dull or misleading, which can make children with color vision deficiency seem “picky” about what they eat.

Modern technology can also be frustrating. Devices that rely on red, green, or orange indicator lights—such as chargers, routers, or electronic gadgets—may be confusing because these colors can appear very similar. Traffic lights can also be difficult to interpret, especially for those with red or green deficiencies.

Color vision deficiency can affect education, careers, and workplace performance. In schools, children may struggle with learning materials, charts, or exams that rely heavily on color, especially when teachers are unaware of the condition. Without proper support, this can impact academic performance and confidence. Later in life, some career paths may be limited, particularly in fields where accurate color recognition is critical for safety.

Despite these challenges, many people with color vision deficiency learn to adapt. However, adaptation does not mean their needs should be ignored. Greater awareness and simple accommodations—such as clear labeling, alternative patterns, or color-safe design—can make a significant difference in daily life.

To learn more about the experiences and challenges of living with color vision deficiency, you can read the full article from Color Blind Awareness at:
''',
    linkUrl:
        ' https://www.colourblindawareness.org/colour-blindness/living-with-colour-vision-deficiency/',
    bottomImages: [
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXe7EvAT1F9eGXypwVShS_m07J_kQ3PVyv419MAyOYfnZOjkJ5tnXe1TYNa_xi04GrOgDW6UdelMUfz-u2XyytXf62kDWKvHCPK8Bl6edzcaII3pyhfqAjSecWukxIkOqWJ6z_JCjQ=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXfUBlZdHWcTIcTdT0uM9MQkkW6Yl1Bq9GdT0GKXyOaQqh3UxXPeYoYK3XLJztw-OE19lc7ehI--qAlRp-mOCdk-SRDPo0Th3TwNGlGeNlFrcIl_ZKKlPBOSMQHUoTwcJze0EzwG=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXdkBJfp4zwD0pGA7pfhPnrRQT6q5_h_b0MneBO2MxK_nHqQjjAGuiYzShynLCk0jrkHeCttxIdxt9ZCkH90GrCkZcSryZ5Nys_goFkvjinFE0Kldit9YlEKSjPKJgIZtIr2b0tzLw=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
    ],
  ),
  Article(
    title: 'Why Color Contrast Accessibility Matters',
    content: '''
Color contrast accessibility plays a vital role in creating inclusive and user-friendly websites and digital platforms. While many organizations focus on color contrast to meet accessibility laws and standards, its importance goes far beyond legal compliance. Proper color contrast helps remove barriers for people with disabilities and ensures that everyone can navigate and understand digital content with ease.

Globally, around 2.2 billion people live with some form of vision impairment. Many of these individuals depend on assistive technologies and accessible web design to complete everyday online tasks. When websites ignore color contrast best practices, users may struggle to distinguish text, buttons, or important visual elements, making the experience frustrating or even unusable. As a result, people are more likely to leave and choose platforms that feel more welcoming and accessible.

Color contrast is especially important for the 295 million people with mild vision loss, who often find it difficult to differentiate between similar colors on a screen. However, poor color contrast does not only affect users with visual impairments—even users with normal vision can experience difficulty when contrast is too low, especially in bright environments or on small screens.

Focusing on color contrast is one of the simplest and most effective accessibility improvements a website can make. It requires relatively little time and effort, yet it can significantly enhance usability, accessibility, and overall user satisfaction. By prioritizing accessible color contrast, organizations demonstrate a commitment to inclusion while improving the experience for all users.

To read more about color contrast accessibility and why it matters, you can visit the full article from Recite Me at:
''',
    linkUrl: ' https://reciteme.com/news/colour-contrast-accessibility/',
    bottomImages: [
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXeE5jfrGE0Lmrn6jjeNAThOm4M8CxCR9IuAyv4Thk3-SlKO3292zZmkPz80hOanK9VJdF2zYReoXuM5EfISgctkBp8xx_wl2ESi2c0PkrMerVvd0nfQ5mfGSoKAHft5hYBrlDxBvw=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
    ],
  ),
  Article(
    title: 'Color Vision Deficiency in Education',
    content: '''
Color vision deficiency can significantly affect a child’s learning experience in school, especially because color is widely used in classrooms and educational materials. Teachers often rely on color to highlight key points, organize information, mark work, and create engaging learning environments. For students with color vision deficiency, this heavy reliance on color can create barriers to understanding and participation.

A child with color vision deficiency may be considered to have a Special Educational Need if their condition affects their ability to take part in everyday school activities. Many learning resources—such as worksheets, charts, graphs, textbooks, and teaching aids—are not designed with color-blind students in mind. As a result, students may struggle to interpret information that is presented using color alone.

One major challenge is that many children with color vision deficiency are undiagnosed. Because they see clearly and assume everyone sees the same way, they may not realize they are missing visual information. This can lead to confusion, embarrassment, and reluctance to participate in class. Over time, a lack of understanding and support can affect confidence, motivation, and overall well-being.

Color-blind students often have to work harder than their peers to interpret colors and translate them into labels others recognize instantly. As students progress through school, difficulties can increase—especially in subjects such as science, math, and geography, where graphs, experiments, and diagrams frequently rely on color coding.

Raising awareness among teachers and providing appropriate classroom adjustments are essential to ensure that students with color vision deficiency are not left behind. Simple changes, such as using patterns, labels, or high-contrast designs instead of color alone, can make a meaningful difference in helping all students access learning equally.

To read more about color vision deficiency and its impact on education, you can explore the full article from Color Blind Awareness at:
''',
    linkUrl: 'https://www.colourblindawareness.org/education/',
    bottomImages: [
      'https://lh7-rt.googleusercontent.com/docsz/AD_4nXcTTQ98XXR26hH16-WzsnygBcLqpGmmmJTrpZ6dDUNq9mIsc8S4RNdewVd0loHLzOjs2NKAfwJ8-igjfVwIMsYbj18Zq2FkjC3EdzPXJ5a-ym4lNTdoedGtEc8viZqWE7AnEp9n8g=s800?key=xQ4DJvuq7Xnx9TubGDHmrA',
    ],
  ),
];
