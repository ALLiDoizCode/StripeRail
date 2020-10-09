import Fluent
import Vapor

func routes(_ app: Application) throws {
    
    let stripeController = StripeController()

    try app.register(collection: stripeController)
}
