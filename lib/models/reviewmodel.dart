class ReviewModel{
  final String userid;
  final String review;
  final String reviewby;

  ReviewModel(this.userid,this.review,this.reviewby);

  factory ReviewModel.fromJson(Map data){
    return ReviewModel(data["userid"], data["review"], data["reviewby"]);
  }
}