class RedmineBacklogs::IssueForm::Heading < RedmineBacklogs::IssueView::Heading
  def render(t)
    t.text_field_tag("issue[subject]", issue.subject.to_s, {:size => 60})
  end
end
